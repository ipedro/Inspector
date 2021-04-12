//
//  ElementViewHierarchyPanelViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ElementViewHierarchyPanelViewModelProtocol: AnyObject {
    var parent: ElementViewHierarchyPanelViewModelProtocol? { get set }
    
    var reference: ViewHierarchyReference { get }
    
    var thumbnailImage: UIImage? { get }
    
    var title: String { get }
    
    var titleFont: UIFont { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isHidden: Bool { get }
    
    var accessoryType: UITableViewCell.AccessoryType { get }
    
    var relativeDepth: Int { get }
}


final class ElementViewHierarchyPanelViewModel {
    
    let identifier = UUID()
    
    weak var parent: ElementViewHierarchyPanelViewModelProtocol?
    
    private var _isCollapsed: Bool
    
    private(set) lazy var title = reference.elementName
    
    private(set) lazy var subtitle = reference.elementDescription
    
    let rootDepth: Int
    
    let thumbnailImage: UIImage?
    
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
