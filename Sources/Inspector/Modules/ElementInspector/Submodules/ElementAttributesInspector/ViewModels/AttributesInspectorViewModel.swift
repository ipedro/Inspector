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

protocol AttributesInspectorViewModelProtocol: ElementViewHierarchyPanelViewModelProtocol {
    var sectionViewModels: [ElementInspectorFormViewModelProtocol] { get }
    
    var isHighlightingViews: Bool { get }
    
    var isLiveUpdating: Bool { get set }
}

final class AttributesInspectorViewModel {
    var isHighlightingViews: Bool {
        reference.isHidingHighlightViews == false
    }
    
    var isLiveUpdating: Bool
    
    let reference: ViewHierarchyReference
    
    let snapshot: ViewHierarchySnapshot
    
    private(set) lazy var sectionViewModels: [ElementInspectorFormViewModelProtocol] = {
        guard let referenceView = reference.rootView else {
            return []
        }
        
        var viewModels = [ElementInspectorFormViewModelProtocol?]()
        
        snapshot.elementLibraries.targeting(element: referenceView).forEach { library in
            viewModels.append(contentsOf: library.viewModels(for: referenceView))
        }
        
        return viewModels.compactMap { $0 }
    }()
    
    init(
        reference: ViewHierarchyReference,
        snapshot: ViewHierarchySnapshot
    ) {
        self.reference = reference
        self.snapshot = snapshot
        self.isLiveUpdating = true
    }
}

// MARK: - AttributesInspectorViewModelProtocol

extension AttributesInspectorViewModel: AttributesInspectorViewModelProtocol {
    var parent: ElementViewHierarchyPanelViewModelProtocol? {
        get { nil }
        set { }
    }

    var thumbnailImage: UIImage? { snapshot.elementLibraries.icon(for: reference.rootView) }
    
    var title: String { reference.elementName }
    
    var titleFont: UIFont { ElementInspector.appearance.titleFont(forRelativeDepth: .zero) }
    
    var subtitle: String { reference.elementDescription }
    
    var isContainer: Bool { false }

    var showCollapseButton: Bool { false }
    
    var isCollapsed: Bool {
        get { true }
        set { }
    }
    
    var isHidden: Bool { false }
    
    var relativeDepth: Int { .zero }
}
