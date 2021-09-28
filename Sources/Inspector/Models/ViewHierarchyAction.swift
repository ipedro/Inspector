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

enum ViewHierarchyAction: Swift.CaseIterable {
    case tap
    case preview
    case attributes
    case size
    case children
    case showHighlight
    case hideHightlight

    var title: String {
        switch self {
        case .tap:
            return "Tap"
        case .preview:
            return "Open Preview"
        case .attributes:
            return "Open Attributes"
        case .children:
            return "Open Children"
        case .size:
            return "Open Size"
        case .showHighlight:
            return "Show Highlight"
        case .hideHightlight:
            return "Hide Highlight"
        }
    }

    var image: UIImage? {
        switch self {
        case .tap:
            return nil
        case .showHighlight:
            return UIImage.moduleImage(named: "binocularsFill")!
        case .hideHightlight:
            return UIImage.moduleImage(named: "binoculars")!
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

    static func actions(for reference: ViewHierarchyReference) -> [ViewHierarchyAction] {
        allCases.filter { action in
            switch action {
            case .tap:
                return false

            case .children:
                return reference.isContainer

            case .showHighlight:
                return !reference.isShowingLayerHighlightView

            case .hideHightlight:
                return reference.isShowingLayerHighlightView

            default:
                return true
            }
        }
    }
}
