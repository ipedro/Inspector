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

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    static var cacheExpirationInterval: TimeInterval {
        HierarchyInspector.configuration.cacheExpirationTimeInterval
    }
    
    let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationInterval)
    
    let availableLayers: [ViewHierarchyLayer]
    
    let populatedLayers: [ViewHierarchyLayer]
    
    let rootReference: ViewHierarchyReference
    
    let inspectableReferences: [ViewHierarchyReference]
    
    let elementLibraries: [HierarchyInspectorElementLibraryProtocol]
    
    init(
        availableLayers: [ViewHierarchyLayer],
        elementLibraries: [HierarchyInspectorElementLibraryProtocol],
        in rootView: UIView
    ) {
        self.availableLayers = availableLayers.uniqueValues
        
        self.elementLibraries = elementLibraries
        
        self.rootReference = ViewHierarchyReference(root: rootView)
        
        self.inspectableReferences = rootReference.inspectableViewReferences
        
        let inspectableViews = rootReference.inspectableViewReferences.compactMap { $0.rootView }
        
        self.populatedLayers = availableLayers.filter {
            $0.filter(flattenedViewHierarchy: inspectableViews).isEmpty == false
        }
    }
    
}

// MARK: - Icon Image

extension ViewHierarchySnapshot {
    
    func iconImage(for view: UIView?, with size: CGSize = .defaultIconSize) -> UIImage? {
        iconImage(for: view)?.resized(size)
    }
    
    private func iconImage(for view: UIView?) -> UIImage? {
        let emptyImage = UIImage.moduleImage(named: "EmptyView-32_Normal")
        
        guard let view = view else {
            return emptyImage
        }
        
        guard view is InternalViewProtocol == false else {
            return UIImage.internalViewIcon?.withRenderingMode(view is UIControl ? .alwaysOriginal : .alwaysTemplate)
        }
        
        if view.isHidden {
            return UIImage.moduleImage(named: "Hidden-32_Normal")
        }
        
        let candidateIcons = elementLibraries.targeting(element: view).compactMap { $0.icon(with: view) }
        
        return candidateIcons.first ?? emptyImage
    }
    
}

private extension UIImage {
    static let internalViewIcon = UIImage.moduleImage(named: "InternalView-32_Normal")
}

private extension CGSize {
    static let defaultIconSize = CGSize(
        width:  ElementInspector.appearance.verticalMargins * 3,
        height: ElementInspector.appearance.verticalMargins * 3
    )
}
