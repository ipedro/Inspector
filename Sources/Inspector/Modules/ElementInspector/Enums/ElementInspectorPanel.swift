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

enum ElementInspectorPanel: CaseIterable, Hashable {
    typealias AllCases = [ElementInspectorPanel]

    case preview
    case attributes
    case children
    case size

    var title: String {
        switch self {
        case .preview:
            return "Preview"
        case .attributes:
            return "Attributes"
        case .children:
            return "Children"
        case .size:
            return "Size"
        }
    }

    var image: UIImage {
        switch self {
        case .preview:
            return IconKit.imageOfInfoCircleFill()

        case .attributes:
            return IconKit.imageOfSliderHorizontal()
            
        case .children:
            return IconKit.imageOfRelationshipDiagram()
            
        case .size:
            return IconKit.imageOfSetSquareFill()
        }
    }
    
    static var allCases: [ElementInspectorPanel] {
        [.preview, .attributes, .size, .children]
    }

    static func cases(for reference: ViewHierarchyReference) -> [ElementInspectorPanel] {
        ElementInspectorPanel.allCases.compactMap { panel in
            switch panel {
            case .children:
                return reference.isContainer ? panel : nil
            case .preview, .size, .attributes:
                return panel
            }
        }
    }
}
