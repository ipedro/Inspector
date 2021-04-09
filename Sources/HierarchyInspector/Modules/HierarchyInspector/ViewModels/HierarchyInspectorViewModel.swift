//
//  HierarchyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

protocol HierarchyInspectorViewModelProtocol: HierarchyInspectorViewModelSectionProtocol {
    var isSearching: Bool { get }
    var searchQuery: String? { get set }
}

protocol HierarchyInspectorCellViewModelProtocol {
    var title: String { get }
    var titleFont: UIFont { get }
    var subtitle: String? { get }
    var image: UIImage? { get }
    var depth: Int { get }
}

protocol HierarchyInspectorViewModelSectionProtocol {
    var numberOfSections: Int { get }
    
    var isEmpty: Bool { get }
    
    func numberOfRows(in section: Int) -> Int
    
    func titleForHeader(in section: Int) -> String?
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat
    
    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModelProtocol
    
    func selectRow(at indexPath: IndexPath) -> ViewHierarchyReference?
    
    func loadData()
}

final class HierarchyInspectorViewModel {
    
    let layerActionsViewModel: LayerActionsViewModel
    
    let snapshotViewModel: SnapshotViewModel
    
    var isSearching: Bool {
        searchQuery.isNilOrEmpty == false
    }
    
    var searchQuery: String? {
        didSet {
            snapshotViewModel.searchQuery = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    init(
        layerActionGroupsProvider: @escaping (() -> ActionGroups),
        snapshot: ViewHierarchySnapshot
    ) {
        layerActionsViewModel = LayerActionsViewModel(layerActionGroupsProvider: layerActionGroupsProvider)
        snapshotViewModel = SnapshotViewModel(snapshot: snapshot)
    }
}

// MARK: - HierarchyInspectorViewModelProtocol

extension HierarchyInspectorViewModel: HierarchyInspectorViewModelProtocol {
    var isEmpty: Bool {
        switch isSearching {
        case true:
            return snapshotViewModel.isEmpty
            
        case false:
            return layerActionsViewModel.isEmpty
        }
    }
    
    func loadData() {
        switch isSearching {
        case true:
            return snapshotViewModel.loadData()
            
        case false:
            return layerActionsViewModel.loadData()
        }
    }
    
    func selectRow(at indexPath: IndexPath) -> ViewHierarchyReference? {
        switch isSearching {
        case true:
            return snapshotViewModel.selectRow(at: indexPath)
            
        case false:
            return layerActionsViewModel.selectRow(at: indexPath)
        }
    }
    
    var numberOfSections: Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfSections
            
        case false:
            return layerActionsViewModel.numberOfSections
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfRows(in: section)
            
        case false:
            return layerActionsViewModel.numberOfRows(in: section)
        }
    }
    
    func titleForHeader(in section: Int) -> String? {
        switch isSearching {
        case true:
            return snapshotViewModel.titleForHeader(in: section)
            
        case false:
            return layerActionsViewModel.titleForHeader(in: section)
        }
    }
    
    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModelProtocol {
        switch isSearching {
        case true:
            return snapshotViewModel.cellViewModelForRow(at: indexPath)
            
        case false:
            return layerActionsViewModel.cellViewModelForRow(at: indexPath)
        }
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        switch isSearching {
        case true:
            return snapshotViewModel.heightForRow(at: indexPath)
            
        case false:
            return layerActionsViewModel.heightForRow(at: indexPath)
        }
    }
}

extension HierarchyInspectorViewModel {
    final class LayerActionsViewModel: HierarchyInspectorViewModelSectionProtocol {
        
        struct CellViewModel: HierarchyInspectorCellViewModelProtocol {
            let title: String
            let titleFont: UIFont = .preferredFont(forTextStyle: .callout)
            let subtitle: String? = nil
            let image: UIImage? = nil
            let depth: Int = 0
        }
        
        private(set) lazy var layerActionGroups = ActionGroups()
        
        let layerActionGroupsProvider: () -> ActionGroups
        
        init(layerActionGroupsProvider: @escaping () -> ActionGroups) {
            self.layerActionGroupsProvider = layerActionGroupsProvider
        }
        
        var isEmpty: Bool {
            var totalActionCount = 0
            
            for group in layerActionGroups {
                totalActionCount += group.actions.count
            }
            
            return totalActionCount == 0
        }
        
        func loadData() {
            layerActionGroups = layerActionGroupsProvider()
        }
        
        func selectRow(at indexPath: IndexPath) -> ViewHierarchyReference? {
            let selectedAction = action(at: indexPath)
            
            DispatchQueue.main.async {
                selectedAction.closure?()
            }
            
            return nil
        }
        
        var numberOfSections: Int {
            layerActionGroups.count
        }
        
        func numberOfRows(in section: Int) -> Int {
            actionGroup(in: section).actions.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            actionGroup(in: section).title
        }
        
        func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModelProtocol {
            let action = self.action(at: indexPath)
            
            return CellViewModel(title: action.title)
        }
        
        func heightForRow(at indexPath: IndexPath) -> CGFloat { 44 }
        
        private func actionGroup(in section: Int) -> ActionGroup {
            layerActionGroups[section]
        }
        
        private func action(at indexPath: IndexPath) -> Action {
            actionGroup(in: indexPath.section).actions[indexPath.row]
        }
    }
}

extension HierarchyInspectorViewModel {
    final class SnapshotViewModel: HierarchyInspectorViewModelSectionProtocol {
        
        struct CellViewModel: HierarchyInspectorCellViewModelProtocol {
            let title: String
            let titleFont: UIFont = .preferredFont(forTextStyle: .footnote)
            let subtitle: String?
            let image: UIImage?
            let depth: Int
            let reference: ViewHierarchyReference
        }
        
        var searchQuery: String? {
            didSet {
                loadData()
            }
        }
        
        let snapshot: ViewHierarchySnapshot
        
        private var searchResults = [CellViewModel]()
        
        init(snapshot: ViewHierarchySnapshot) {
            self.snapshot = snapshot
        }
        
        var isEmpty: Bool { searchResults.isEmpty }
        
        let numberOfSections = 1
        
        func selectRow(at indexPath: IndexPath) ->ViewHierarchyReference? {
            searchResults[indexPath.row].reference
        }
        
        func numberOfRows(in section: Int) -> Int {
            searchResults.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            "\(searchResults.count) Search results in \(snapshot.viewHierarchy.elementName)"
        }
        
        func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModelProtocol {
            searchResults[indexPath.row]
        }
        
        func heightForRow(at indexPath: IndexPath) -> CGFloat { 66 }
        
        func loadData() {
            guard let searchQuery = searchQuery else {
                searchResults = []
                return
            }
            
            let flattenedViewHierarchy = [snapshot.viewHierarchy] + snapshot.flattenedViewHierarchy
            
            searchResults = flattenedViewHierarchy.filter {
                $0.elementName.localizedCaseInsensitiveContains(searchQuery)
            }.map({ element -> CellViewModel in
                
                let title: String = {
                    if
                        let textElement = element.view as? TextElement,
                        let text = textElement.content
                    {
                        return "\"\(text)\""
                    }
                    
                    return element.elementName
                }()
                
                return CellViewModel(
                    title: title,
                    subtitle: element.elementDescription,
                    image: element.iconImage(
                        with: CGSize(
                            width: ElementInspector.appearance.horizontalMargins,
                            height: ElementInspector.appearance.horizontalMargins
                        )
                    ),
                    depth: element.depth,
                    reference: element
                )
            })
        }
        
    }
}

extension AttributesInspectorSection {
    
    private func bundleImage(named imageName: String) -> UIImage {
        guard let image = UIImage(named: imageName, in: .module, compatibleWith: nil) else {
            fatalError("Couldn't find iamge named \(imageName)")
        }
        
        return image
    }
    
    var image: UIImage {
        switch self {
        
        case .activityIndicator:
            return bundleImage(named: "UIActivityIndicator_32_Dark_Normal")
            
        case .button:
            return bundleImage(named: "UIButton_32-Dark_Normal")
            
        case .datePicker:
            return bundleImage(named: "UIDatePicker_32_Normal")
            
        case .imageView:
            return bundleImage(named: "UIImageView-32_Normal")
            
        case .label:
            return bundleImage(named: "UILabel_32-Dark_Normal")
            
        case .scrollView:
            return bundleImage(named: "UIScrollView_32_Normal")
            
        case .segmentedControl:
            return bundleImage(named: "UISegmentedControl_32_Normal")
            
        case .switch:
            return bundleImage(named: "Toggle-32_Normal")
            
        case .stackView:
            return bundleImage(named: "VStack-32_Normal")
            
        case .textField:
            return bundleImage(named: "TextField-32_Normal")
            
        case .textView:
            return bundleImage(named: "TextView-32_Normal")
            
        case .mapView,
             .control,
             .slider,
             .view:
            return bundleImage(named: "EmptyView-32_Normal")
            
        }
    }
}

protocol TextElement: UIView {
    var content: String? { get }
}

extension UILabel: TextElement {
    var content: String? { text }
}

extension UITextView: TextElement {
    var content: String? { text }
}

extension UITextField: TextElement {
    var content: String? { text }
}
