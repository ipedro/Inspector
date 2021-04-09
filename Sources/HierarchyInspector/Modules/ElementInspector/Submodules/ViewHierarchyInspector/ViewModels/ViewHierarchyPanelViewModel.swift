//
//  ElementInspector.ViewHierarchyPanelViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ElementInspectorViewHierarchyPanelViewModelProtocol: AnyObject {
    var parent: ElementInspectorViewHierarchyPanelViewModelProtocol? { get set }
    
    var reference: ViewHierarchyReference { get }
    
    var thumbnailImage: UIImage? { get }
    
    var title: String { get }
    
    var titleFont: UIFont { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isHidden: Bool { get }
    
    var showDisclosureIndicator: Bool { get }
    
    var relativeDepth: Int { get }
}

extension ElementInspector {
    final class ViewHierarchyPanelViewModel {
        
        let identifier = UUID()
        
        weak var parent: ElementInspectorViewHierarchyPanelViewModelProtocol?
        
        private var _isCollapsed: Bool
        
        private(set) lazy var title = reference.elementName
        
        private(set) lazy var subtitle = reference.elementDescription
        
        let rootDepth: Int
        
        
        
        private(set) lazy var thumbnailImage: UIImage? = reference.iconImage(with: Self.thumbSize)
        
        // MARK: - Properties
        
        let reference: ViewHierarchyReference
        
        static let thumbSize = CGSize(
            width: ElementInspector.appearance.horizontalMargins * 2,
            height: ElementInspector.appearance.horizontalMargins * 2
        )
        
        init(
            reference: ViewHierarchyReference,
            parent: ElementInspectorViewHierarchyPanelViewModelProtocol? = nil,
            rootDepth: Int,
            isCollapsed: Bool
        ) {
            self.parent = parent
            self.reference = reference
            self.rootDepth = rootDepth
            self._isCollapsed = isCollapsed
        }
    }
}

// MARK: - ElementInspectorViewHierarchyPanelViewModelProtocol

extension ElementInspector.ViewHierarchyPanelViewModel: ElementInspectorViewHierarchyPanelViewModelProtocol {
    var titleFont: UIFont {
        ElementInspector.appearance.titleFont(forRelativeDepth: relativeDepth)
    }
    
    var isHidden: Bool {
        parent?.isCollapsed == true || parent?.isHidden == true
    }
    
    var showDisclosureIndicator: Bool {
        false
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

extension ElementInspector.ViewHierarchyPanelViewModel: Hashable {
    static func == (lhs: ElementInspector.ViewHierarchyPanelViewModel, rhs: ElementInspector.ViewHierarchyPanelViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
}

// MARK: - Images

private extension ElementInspector.ViewHierarchyPanelViewModel {
    
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
