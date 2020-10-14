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
    
    var thumbnailView: UIView { get }
    
    var hasCachedThumbnailView: Bool { get }
    
    func clearCachedThumbnail()
    
    var title: String { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isHidden: Bool { get }
    
    var showDisclosureIndicator: Bool { get }
    
    var relativeDepth: Int { get }
    
    var backgroundColor: UIColor? { get }
}

final class ViewHierarchyListItemViewModel: ViewHierarchyListItemViewModelProtocol {
    
    let identifier = UUID()
    
    weak var parent: ViewHierarchyListItemViewModelProtocol?
    
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
    
    func clearCachedThumbnail() {
        cachedReferenceThumbnail = nil
    }
    
    private var _isCollapsed: Bool
    
    var backgroundColor: UIColor? {
        UIColor(white: 1 - CGFloat(relativeDepth) * 0.03, alpha: 1)
    }
    
    private(set) lazy var title = reference.elementName
    
    private(set) lazy var subtitle = reference.elementDescription
    
    var isContainer: Bool { reference.isContainer }
    
    var relativeDepth: Int {
        reference.depth - rootDepth
    }
    
    let rootDepth: Int
    
    // MARK: - Properties
    
    let reference: ViewHierarchyReference
    
    static let thumbSize = CGSize(
        width: ElementInspector.appearance.horizontalMargins * 2,
        height: ElementInspector.appearance.horizontalMargins * 2
    )
    
    var cachedReferenceThumbnail: ViewHierarchyReferenceThumbnailView?
    
    var hasCachedThumbnailView: Bool {
        cachedReferenceThumbnail != nil
    }
    
    func makeReferenceThumbnailmage() -> ViewHierarchyReferenceThumbnailView {
        let thumbnailView = ViewHierarchyReferenceThumbnailView(
            frame: CGRect(
                origin: .zero,
                size: Self.thumbSize
            ),
            reference: reference
        )
        
        thumbnailView.showEmptyStatusMessage = false
        thumbnailView.layer.shouldRasterize = true
        thumbnailView.heightAnchor.constraint(equalToConstant: Self.thumbSize.height).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: Self.thumbSize.width).isActive = true
        thumbnailView.contentView.directionalLayoutMargins = .margins(ElementInspector.appearance.verticalMargins / 2)
        thumbnailView.updateViews(afterScreenUpdates: false)
        
        return thumbnailView
    }
    
    var thumbnailView: UIView {
        guard let cachedReferenceThumbnail = cachedReferenceThumbnail else {
            let newReference = makeReferenceThumbnailmage()
            self.cachedReferenceThumbnail = newReference
            
            return newReference
        }
        
        return cachedReferenceThumbnail
    }
    
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

extension ViewHierarchyListItemViewModel: Hashable {
    static func == (lhs: ViewHierarchyListItemViewModel, rhs: ViewHierarchyListItemViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
}
