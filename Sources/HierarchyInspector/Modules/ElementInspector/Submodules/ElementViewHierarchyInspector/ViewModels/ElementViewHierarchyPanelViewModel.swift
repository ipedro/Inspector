//
//  ElementViewHierarchyPanelViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ElementViewHierarchyPanelViewModelProtocol: ViewHierarchyReferenceDetailViewModelProtocol & AnyObject {
    var parent: ElementViewHierarchyPanelViewModelProtocol? { get set }
    
    var reference: ViewHierarchyReference { get }
    
    var accessoryType: UITableViewCell.AccessoryType { get }
}


final class ElementViewHierarchyPanelViewModel {
    
    let identifier = UUID()
    
    weak var parent: ElementViewHierarchyPanelViewModelProtocol?
    
    private var _isCollapsed: Bool
    
    var title: String { reference.elementName }
    
    var subtitle: String { reference.elementDescription }
    
    let rootDepth: Int
    
    var thumbnailImage: UIImage?
    
    // MARK: - Properties
    
    let reference: ViewHierarchyReference
    
    init(
        reference: ViewHierarchyReference,
        parent: ElementViewHierarchyPanelViewModelProtocol? = nil,
        rootDepth: Int,
        thumbnailImage: UIImage?,
        isCollapsed: Bool
    ) {
        self.parent = parent
        self.reference = reference
        self.rootDepth = rootDepth
        self.thumbnailImage = thumbnailImage
        self._isCollapsed = isCollapsed
    }
}


// MARK: - ElementViewHierarchyPanelViewModelProtocol

extension ElementViewHierarchyPanelViewModel: ElementViewHierarchyPanelViewModelProtocol {
    
    var titleFont: UIFont {
        ElementInspector.appearance.titleFont(forRelativeDepth: relativeDepth)
    }
    
    var isHidden: Bool {
        parent?.isCollapsed == true || parent?.isHidden == true
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        .detailButton
    }
    
    var isCollapsed: Bool {
        get {
            isContainer ? _isCollapsed : true
        }
        set {
            guard isContainer else {
                return
            }
            
            _isCollapsed = newValue
        }
    }
    
    var isContainer: Bool {
        reference.isContainer
    }
    
    var relativeDepth: Int {
        reference.depth - rootDepth
    }
    
    var isChevronHidden: Bool {
        isContainer != true || accessoryType == .disclosureIndicator
    }
}

// MARK: - Hashable

extension ElementViewHierarchyPanelViewModel: Hashable {
    static func == (lhs: ElementViewHierarchyPanelViewModel, rhs: ElementViewHierarchyPanelViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
}

// MARK: - Images

private extension ElementViewHierarchyPanelViewModel {
    
    static let thumbnailImageLostConnection = IconKit.imageOfWifiExlusionMark(
        CGSize(
            width: ElementInspector.appearance.horizontalMargins * 1.5,
            height: ElementInspector.appearance.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)
    
    static let thumbnailImageIsHidden = IconKit.imageOfEyeSlashFill(
        CGSize(
            width: ElementInspector.appearance.horizontalMargins * 1.5,
            height: ElementInspector.appearance.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)
    
}
