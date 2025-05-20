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

enum ElementInspectorPanel: Hashable, Swift.CaseIterable, MenuContentProtocol {
    case identity
    case attributes
    case size
    case children

    static var `default`: ElementInspectorPanel { Inspector.sharedInstance.configuration.elementInspectorConfiguration.defaultPanel }

    var title: String {
        switch self {
        case .identity:
            Texts.inspect("Identity")
        case .attributes:
            Texts.inspect("Attributes")
        case .children:
            Texts.inspect("Children")
        case .size:
            Texts.inspect("Size")
        }
    }

    var image: UIImage? {
        switch self {
        case .identity:
            .elementIdentityPanel
        case .attributes:
            .elementAttributesPanel
        case .children:
            .elementChildrenPanel
        case .size:
            .elementSizePanel
        }
    }

    var isDefault: Bool {
        self == .default
    }

    static func allCases(for element: ViewHierarchyElementReference) -> [ElementInspectorPanel] {
        allCases.filter { panel in
            switch panel {
            case .children:
                element.isContainer

            case .size:
                element._underlyingObject is UIView

            case .identity, .attributes:
                true
            }
        }
    }
}
