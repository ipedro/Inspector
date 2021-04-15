//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    static var cacheExpirationInterval: TimeInterval {
        HierarchyInspector.configuration.cacheExpirationTimeInterval
    }
    
    let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationInterval)
    
    let availableLayers: [ViewHierarchyLayer]
    
    let populatedLayers: [ViewHierarchyLayer]
    
    let rootReference: ViewHierarchyReference
    
    let inspectableReferences: [ViewHierarchyReference]
    
    let elementLibraries: [HierarchyInspectorElementLibraryProtocol]
    
    init(
        availableLayers: [ViewHierarchyLayer],
        elementLibraries: [HierarchyInspectorElementLibraryProtocol],
        in rootView: UIView
    ) {
        self.availableLayers = availableLayers.uniqueValues
        
        self.elementLibraries = elementLibraries
        
        self.rootReference = ViewHierarchyReference(root: rootView)
        
        self.inspectableReferences = rootReference.inspectableViewReferences
        
        let inspectableViews = rootReference.inspectableViewReferences.compactMap { $0.rootView }
        
        self.populatedLayers = availableLayers.filter {
            $0.filter(flattenedViewHierarchy: inspectableViews).isEmpty == false
        }
    }
    
}

// MARK: - Icon Image

extension ViewHierarchySnapshot {
    
    func iconImage(for view: UIView?, with size: CGSize = .defaultIconSize) -> UIImage {
        iconImage(for: view).resized(size)
    }
    
    private func iconImage(for view: UIView?) -> UIImage {
        switch view {
        case is InternalViewProtocol:
            return UIImage.internalViewIcon.withRenderingMode(view is UIControl ? .alwaysOriginal : .alwaysTemplate)
            
        case let view?:
            let candidateIcons = elementLibraries.targeting(element: view).compactMap { $0.icon(with: view) }
            
            if let firstIcon = candidateIcons.first {
                return firstIcon
            }
            
        default:
            break
        }
        
        return UIImage.moduleImage(named: "EmptyView-32_Normal")
    }
    
}

private extension UIImage {
    static let internalViewIcon = UIImage.moduleImage(named: "InternalView-32_Normal")
}

private extension CGSize {
    static let defaultIconSize = CGSize(
        width:  ElementInspector.appearance.verticalMargins * 3,
        height: ElementInspector.appearance.verticalMargins * 3
    )
}
