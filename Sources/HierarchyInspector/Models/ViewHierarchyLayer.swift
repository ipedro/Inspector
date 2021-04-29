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

typealias ViewHierarchyLayer = HierarchyInspector.ViewHierarchyLayer

extension HierarchyInspector {
    public struct ViewHierarchyLayer {
        
        public typealias Filter = (UIView) -> Bool
        
        // MARK: - Properties
        
        public var name: String
        
        var showLabels: Bool = true
        
        var allowsSystemViews: Bool = false
        
        public var filter: Filter
        
        // MARK: - Init
        
        public static func layer(name: String, filter: @escaping Filter) -> ViewHierarchyLayer {
            ViewHierarchyLayer(name: name, filter: filter)
        }
        
        // MARK: - Metods
        
        func filter(snapshot: ViewHierarchySnapshot) -> [UIView] {
            let inspectableViews = snapshot.inspectableReferences.compactMap { $0.rootView }
            
            return filter(flattenedViewHierarchy: inspectableViews)
        }
        
        func filter(flattenedViewHierarchy: [UIView]) -> [UIView] {
            let filteredViews = flattenedViewHierarchy.filter(filter)
            
            switch allowsSystemViews {
            case true:
                return filteredViews
                
            case false:
                return filteredViews.filter { $0.isSystemView == false }
            }
        }
        
    }
}
