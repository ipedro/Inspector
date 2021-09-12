//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

final class ViewHierarchyReference {
    weak var rootView: UIView?
    
    let canPresentOnTop: Bool
    
    let canHostInspectorView: Bool
    
    let viewIdentifier: ObjectIdentifier
    
    let isSystemView: Bool
    
    private let _className: String
    
    private let _elementName: String
    
    let frame: CGRect
    
    let accessibilityIdentifier: String?
    
    var parent: ViewHierarchyReference?
    
    var isUserInteractionEnabled: Bool
    
    private(set) lazy var isContainer: Bool = children.isEmpty == false
    
    private(set) lazy var deepestAbsoulteLevel: Int = children.map(\.depth).max() ?? depth
    
    private(set) lazy var children: [ViewHierarchyReference] = rootView?.originalSubviews.map { ViewHierarchyReference(root: $0, depth: depth + 1, parent: self) } ?? []
    
    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - depth
    }
    
    var depth: Int {
        didSet {
            guard let view = rootView else {
                children = []
                return
            }
            
            children = view.originalSubviews.map { ViewHierarchyReference(root: $0, depth: depth + 1, parent: self) }
        }
    }
    
    init(root: UIView, depth: Int = 0, parent: ViewHierarchyReference? = nil) {
        rootView = root
        
        self.depth = depth
        
        self.parent = parent
        
        viewIdentifier = ObjectIdentifier(root)
        
        canPresentOnTop = root.canPresentOnTop
        
        isUserInteractionEnabled = root.isUserInteractionEnabled
        
        _className = root.className
        
        _elementName = root.elementName
        
        isSystemView = root.isSystemView
        
        frame = root.frame
        
        accessibilityIdentifier = root.accessibilityIdentifier
        
        canHostInspectorView = root.canHostInspectorView
    }
}

// MARK: - ViewHierarchyProtocol {

extension ViewHierarchyReference: ViewHierarchyProtocol {
    var elementName: String {
        guard let rootView = rootView else {
            return _elementName
        }
        
        return rootView.elementName
    }
    
    var className: String {
        rootView?.className ?? _className
    }
    
    var displayName: String {
        guard let rootView = rootView else {
            return _elementName
        }
        
        return rootView.displayName
    }
    
    var flattenedSubviewReferences: [ViewHierarchyReference] {
        let array = children.flatMap { [$0] + $0.flattenedSubviewReferences }
        
        return array
    }
    
    var inspectableViewReferences: [ViewHierarchyReference] {
        let flattenedViewHierarchy = [self] + flattenedSubviewReferences
        
        let inspectableViews = flattenedViewHierarchy.filter(\.canHostInspectorView)
        
        return inspectableViews
    }
}

// MARK: - Hashable

extension ViewHierarchyReference: Hashable {
    static func == (lhs: ViewHierarchyReference, rhs: ViewHierarchyReference) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        viewIdentifier.hash(into: &hasher)
    }
}

extension ViewHierarchyReference {
    var isHidingHighlightViews: Bool {
        guard let view = rootView else {
            return false
        }
        
        for view in view.allSubviews where view is LayerViewProtocol {
            if view.isHidden {
                return true
            }
        }
        
        return false
    }
}
