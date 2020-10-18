//
//  ViewHierarchyListItemViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ViewHierarchyListItemViewModelProtocol: AnyObject {
    var parent: ViewHierarchyListItemViewModelProtocol? { get set }
    
    var reference: ViewHierarchyReference { get }
    
    var thumbnailImage: UIImage? { get }
    
    var hasCachedThumbnailImage: Bool { get }
    
    var title: String { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isHidden: Bool { get }
    
    var showDisclosureIndicator: Bool { get }
    
    var relativeDepth: Int { get }
    
    func clearCachedThumbnail()
}

final class ViewHierarchyListItemViewModel {
    
    let identifier = UUID()
    
    weak var parent: ViewHierarchyListItemViewModelProtocol?
    
    private var _isCollapsed: Bool
    
    private(set) lazy var title = reference.elementName
    
    private(set) lazy var subtitle = reference.elementDescription
    
    let rootDepth: Int
    
    // MARK: - Properties
    
    let reference: ViewHierarchyReference
    
    static let thumbSize = CGSize(
        width: ElementInspector.appearance.horizontalMargins * 2,
        height: ElementInspector.appearance.horizontalMargins * 2
    )
    
    var cachedThumbnailImage: UIImage?
    
    init(
        reference: ViewHierarchyReference,
        parent: ViewHierarchyListItemViewModelProtocol? = nil,
        rootDepth: Int,
        isCollapsed: Bool
    ) {
        self.parent = parent
        self.reference = reference
        self.rootDepth = rootDepth
        self._isCollapsed = isCollapsed
    }
}

// MARK: - ViewHierarchyListItemViewModelProtocol

extension ViewHierarchyListItemViewModel: ViewHierarchyListItemViewModelProtocol {
    var isHidden: Bool {
        parent?.isCollapsed == true || parent?.isHidden == true
    }
    
    var showDisclosureIndicator: Bool {
        relativeDepth >= 5 && isContainer
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
    
    var thumbnailImage: UIImage? {
        if cachedThumbnailImage != nil {
            return cachedThumbnailImage
        }
        
        guard let referenceView = reference.view else {
            return Self.thumbnailImageLostConnection
        }
        
        guard referenceView.isHidden == false, referenceView.frame.isEmpty == false else {
            return Self.thumbnailImageIsHidden
        }
        
        cachedThumbnailImage = referenceView.snapshot(afterScreenUpdates: false, with: Self.thumbSize)
        
        return cachedThumbnailImage
    }
    
    var hasCachedThumbnailImage: Bool {
        cachedThumbnailImage != nil
    }
    
    func clearCachedThumbnail() {
        cachedThumbnailImage = nil
    }
}

// MARK: - Hashable

extension ViewHierarchyListItemViewModel: Hashable {
    static func == (lhs: ViewHierarchyListItemViewModel, rhs: ViewHierarchyListItemViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
}

// MARK: - Images

private extension ViewHierarchyListItemViewModel {
    
    static let thumbnailImageLostConnection = IconKit.imageOfWifiExlusionMark().withRenderingMode(.alwaysTemplate)
    
    static let thumbnailImageIsHidden = IconKit.imageOfEyeSlashFill().withRenderingMode(.alwaysTemplate)
    
}
