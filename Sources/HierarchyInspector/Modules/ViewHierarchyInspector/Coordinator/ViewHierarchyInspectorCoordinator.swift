//
//  ViewHierarchyInspectorCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

protocol ViewHierarchyLayerCoordinatorDelegate: AnyObject {
    func viewHierarchyLayerCoordinator(_ coordinator: ViewHierarchyInspectorCoordinator,
                                       didSelect viewHierarchyReference: ViewHierarchyReference,
                                       from highlightView: HighlightView)
}

protocol ViewHierarchyLayerCoordinatorDataSource: AnyObject {
    var viewHierarchySnapshot: ViewHierarchySnapshot? { get }
    
    var colorScheme: ViewHierarchyColorScheme { get }
    
    var availableInspectorLayers: [ViewHierarchyLayer] { get }
}

#warning("migrate to OperationQueue")
struct Operation: Equatable {
    let identifier = UUID()
    
    let name: String
    
    let closure: Closure
    
    static func == (lhs: Operation, rhs: Operation) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

final class ViewHierarchyInspectorCoordinator: Create {
    weak var delegate: ViewHierarchyLayerCoordinatorDelegate?
    
    weak var dataSource: ViewHierarchyLayerCoordinatorDataSource?
    
    var wireframeViews: [ViewHierarchyReference: WireframeView] = [:] {
        didSet {
            updateLayerViews(to: wireframeViews, from: oldValue)
        }
    }
    
    var inspectorViews: [ViewHierarchyReference: HighlightView] = [:] {
        didSet {
            updateLayerViews(to: inspectorViews, from: oldValue)
        }
    }
    
    var viewHierarchyReferences: [ViewHierarchyLayer: [ViewHierarchyReference]] = [:] {
        didSet {
            let layers = Set<ViewHierarchyLayer>(viewHierarchyReferences.keys)
            let oldLayers = Set<ViewHierarchyLayer>(oldValue.keys)
            let newLayers = layers.subtracting(oldLayers)
            let removedLayers = oldLayers.subtracting(layers)
            
            removeReferences(for: removedLayers, in: oldValue)
            
            guard let colorScheme = dataSource?.colorScheme else {
                return
            }
            
            addReferences(for: newLayers, with: colorScheme)
        }
    }
    
}

extension ViewHierarchyInspectorCoordinator {
    
    public var isShowingLayers: Bool {
        viewHierarchyReferences.keys.isEmpty == false
    }
    
    func invalidate() {
        viewHierarchyReferences.removeAll()
        
        wireframeViews.removeAll()
        
        inspectorViews.removeAll()
    }
    
    var activeLayers: [ViewHierarchyLayer] {
        viewHierarchyReferences.compactMap { dict -> ViewHierarchyLayer? in
            guard dict.value.isEmpty == false else {
                return nil
            }
            
            return dict.key
        }
    }
    
    var availableLayers: [ViewHierarchyLayer] {
        dataSource?.viewHierarchySnapshot?.availableLayers ?? []
    }
    
    var populatedLayers: [ViewHierarchyLayer] {
        dataSource?.viewHierarchySnapshot?.populatedLayers ?? []
    }
    
    func hideAllHighlightViews(_ hide: Bool, containedIn reference: ViewHierarchyReference) {
        guard let referenceView = reference.view else {
            return
        }
        
        for view in referenceView.allSubviews where view is LayerViewProtocol {
            view.isSafelyHidden = hide
        }
    }
    
    func updateLayerViews(to newValue: [ViewHierarchyReference: LayerView], from oldValue: [ViewHierarchyReference: LayerView]) {
        let viewReferences = Set<ViewHierarchyReference>(newValue.keys)
        
        let oldViewReferences = Set<ViewHierarchyReference>(oldValue.keys)
        
        let removedReferences = oldViewReferences.subtracting(viewReferences)
        
        let newReferences = viewReferences.subtracting(oldViewReferences)
        
        removedReferences.forEach {
            guard let layerView = oldValue[$0] else {
                return
            }
            
            layerView.removeFromSuperview()
        }
        
        newReferences.forEach {
            guard
                let referenceView = $0.view,
                let inspectorView = newValue[$0]
            else {
                return
            }
            
            referenceView.installView(inspectorView, .autoResizingMask)
        }
    }
    
    func removeReferences(for removedLayers: Set<ViewHierarchyLayer>, in oldValue: [ViewHierarchyLayer: [ViewHierarchyReference]]) {
        var removedReferences = [ViewHierarchyReference]()
        
        removedLayers.forEach { layer in
            Console.print("\(layer) was removed")
            
            oldValue[layer]?.forEach {
                print("[Hierarchy Inspector] \(layer): removing reference to \($0.elementName)")
                removedReferences.append($0)
            }
        }
        
        for (layer, references) in viewHierarchyReferences where layer != .wireframes {
            references.forEach { reference in
                
                if let index = removedReferences.firstIndex(of: reference) {
                    print("[Hierarchy Inspector] reference to \(reference.elementName) reclaimed by \(layer)")
                    
                    removedReferences.remove(at: index)
                }
            }
        }
        
        removedReferences.forEach { removedReference in
            inspectorViews.removeValue(forKey: removedReference)
        }
        
        if removedLayers.contains(.wireframes) {
            wireframeViews.removeAll()
        }
    }
    
    func addReferences(for newLayers: Set<ViewHierarchyLayer>, with colorScheme: ColorScheme) {
        for newLayer in newLayers {
            guard let references = viewHierarchyReferences[newLayer] else {
                continue
            }
            
            switch newLayer.showLabels {
            case true:
                references.forEach { viewReference in
                    guard
                        inspectorViews[viewReference] == nil,
                        let element = viewReference.view
                    else {
                        return
                    }
                    
                    let inspectorView = HighlightView(frame: element.bounds, name: element.className, colorScheme: colorScheme, reference: viewReference)
                    inspectorView.delegate = self
                    
                    inspectorViews[viewReference] = inspectorView
                }
                
            case false:
                references.forEach { viewReference in
                    guard
                        inspectorViews[viewReference] == nil,
                        let element = viewReference.view
                    else {
                        return
                    }
                    
                    let wireframeView = WireframeView(frame: element.bounds, reference: viewReference)
                    
                    wireframeViews[viewReference] = wireframeView
                }
            }
        }
    }
    
}

extension ViewHierarchyInspectorCoordinator: HighlightViewDelegate {
    func highlightView(_ highlightView: HighlightView, didTapWith reference: ViewHierarchyReference) {
        delegate?.viewHierarchyLayerCoordinator(self, didSelect: reference, from: highlightView)
    }
    
}

extension ViewHierarchyInspectorCoordinator {
    
    func asyncOperation(name: String, execute closure: @escaping Closure) {
        async(operation: Operation(name: name, closure: closure), in: dataSource?.viewHierarchySnapshot?.viewHierarchy.view?.window)
    }
    
    private func async(operation: Operation, in window: UIWindow?) {
        window?.showActivityIndicator(for: operation)
        
        DispatchQueue.main.async {
            operation.closure()
            
            window?.removeActivityIndicator(for: operation)
        }
    }
    
}

extension ViewHierarchyInspectorCoordinator {
    
    func layerActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup {
        let layerToggleInputRange = HierarchyInspector.configuration.keyCommands.layerToggleInputRange
        
        let maxCount = layerToggleInputRange.upperBound - layerToggleInputRange.lowerBound
        
        var actions = snapshot.availableLayers.map { layer in
            layerAction(layer, isEmpty: snapshot.populatedLayers.contains(layer) == false)
        }
        
        actions.append(layerAction(.internalViews, isEmpty: false))
        
        return ActionGroup(
            title: actions.isEmpty ? Texts.noLayers : Texts.layers(actions.count),
            actions: Array(actions.prefix(maxCount))
        )
    }
    
    func layerAction(_ layer: ViewHierarchyLayer, isEmpty: Bool) -> Action {
        if isEmpty {
            return .emptyLayer(layer.emptyActionTitle)
        }
        
        switch isShowingLayer(layer) {
        case true:
            return .toggleLayer(layer.selectedActionTitle) { [weak self] in
                self?.removeLayer(layer)
            }
            
        case false:
            return .toggleLayer(layer.unselectedActionTitle) { [weak self] in
                self?.installLayer(layer)
            }
        }
    }
    
    func otherActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup {
        ActionGroup(
            title: nil,
            actions: {
                var array = [Action]()
                
                if activeLayers.count > .zero {
                    array.append(
                        .hideVisibleLayers { [weak self] in self?.removeAllLayers() }
                    )
                }
                
                if activeLayers.count < populatedLayers.count {
                    array.append(
                        .showAllLayers { [weak self] in self?.installAllLayers() }
                    )
                }
                
                return array
            }()
        )
    }
}
