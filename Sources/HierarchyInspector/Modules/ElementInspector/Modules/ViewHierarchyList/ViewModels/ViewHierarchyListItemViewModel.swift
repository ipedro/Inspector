//
//  ViewHierarchyListItemViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ViewHierarchyListItemViewModelProtocol: AnyObject {
    var parent: ViewHierarchyListItemViewModel? { get set }
    
    var title: String { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isHidden: Bool { get }
    
    var relativeDepth: Int { get }
    
    var backgroundColor: UIColor? { get }
}

final class ViewHierarchyListItemViewModel: ViewHierarchyListItemViewModelProtocol {
    let identifier = UUID()
    
    weak var parent: ViewHierarchyListItemViewModel?
    
    var isHidden: Bool {
        parent?.isCollapsed == true || parent?.isHidden == true
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
    
    private var _isCollapsed = false
    
    var backgroundColor: UIColor? {
        UIColor(white: 1 - CGFloat(relativeDepth) * 0.03, alpha: 1)
    }
    
    private(set) lazy var title = reference.elementName
    
    private(set) lazy var subtitle: String = {
        var strings = [String?]()
        
        var constraints: String? {
            guard let view = reference.view else {
                return nil
            }
            return "\(view.constraints.count) constraints"
        }
        
        var subviews: String? {
            guard isContainer else {
                return nil
            }
            return "\(reference.flattenedViewHierarchy.count) children. (\(reference.children.count) subviews)"
        }
        
        var frame: String? {
            guard let view = reference.view else {
                return nil
            }
            
            return "width: \(view.frame.width), height: \(view.frame.height)\nx: \(view.frame.origin.x), y: \(view.frame.origin.y)\n"
        }
        
        var className: String? {
            guard let view = reference.view else {
                return nil
            }
            
            guard let superclass = view.superclass else {
                return view.className
            }
            
            return "\(view.className) (\(String(describing: superclass)))"
        }
        
        strings.append(className)
        
        strings.append(frame)
        
        strings.append(subviews)
        strings.append(constraints)
        
        return strings.compactMap { $0 }.joined(separator: "\n")
    }()
    
    private(set) lazy var isContainer: Bool = reference.children.isEmpty == false
    
    var relativeDepth: Int {
        reference.depth - rootDepth
    }
    
    let rootDepth: Int
    
    // MARK: - Properties
    
    private let reference: ViewHierarchyReference
    
    init(
        reference: ViewHierarchyReference,
        parent: ViewHierarchyListItemViewModel? = nil,
        rootDepth: Int
    ) {
        self.parent = parent
        self.reference = reference
        self.rootDepth = rootDepth
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
