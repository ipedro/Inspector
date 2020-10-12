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
    
    var referenceForThumbnail: ViewHierarchyReference? { get }
    
    var title: String { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isHidden: Bool { get }
    
    var relativeDepth: Int { get }
    
    var backgroundColor: UIColor? { get }
}

final class ViewHierarchyListItemViewModel: ViewHierarchyListItemViewModelProtocol {
    var referenceForThumbnail: ViewHierarchyReference? {
        relativeDepth == 0 ? nil : reference 
    }
    
    let identifier = UUID()
    
    weak var parent: ViewHierarchyListItemViewModelProtocol?
    
    var isHidden: Bool {
        parent?.isCollapsed == true || parent?.isHidden == true
    }
    
    var isCollapsed: Bool {
        get {
            isContainer && relativeDepth < 5 ? _isCollapsed : true
        }
        set {
            guard isContainer else {
                return
            }
            
            _isCollapsed = newValue
        }
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
