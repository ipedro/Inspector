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

enum HierarchyInspectorCellViewModel {
    case layerAction(HierarchyInspectorLayerAcionCellViewModelProtocol)
    case snaphot(HierarchyInspectorSnapshotCellViewModelProtocol)
    
    var cellClassForCoder: AnyClass {
        switch self {
        case .layerAction:
            return HierarchyInspectorLayerActionCell.classForCoder()
            
        case .snaphot:
            return HierarchyInspectorSnapshotCell.classForCoder()
        }
    }
}

protocol HierarchyInspectorViewModelSectionProtocol {
    var numberOfSections: Int { get }
    
    var isEmpty: Bool { get }
    
    func numberOfRows(in section: Int) -> Int
    
    func titleForHeader(in section: Int) -> String?
    
    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel
    
    func selectRow(at indexPath: IndexPath) -> ViewHierarchyReference?
    
    func isRowEnabled(at indexPath: IndexPath) -> Bool
    
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
            let trimmedQuery = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
            snapshotViewModel.searchQuery = trimmedQuery?.isEmpty == false ? trimmedQuery : nil
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
    func isRowEnabled(at indexPath: IndexPath) -> Bool {
        switch isSearching {
        case true:
            return snapshotViewModel.isRowEnabled(at: indexPath)
            
        case false:
            return layerActionsViewModel.isRowEnabled(at: indexPath)
        }
    }
    
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
    
    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
        switch isSearching {
        case true:
            return snapshotViewModel.cellViewModelForRow(at: indexPath)
            
        case false:
            return layerActionsViewModel.cellViewModelForRow(at: indexPath)
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
