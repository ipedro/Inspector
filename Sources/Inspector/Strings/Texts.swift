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

import Foundation

enum Texts {
    static let `default` = "Default"
    static let actions = "Actions"
    static let allHighlights = "All Highlights"
    static let cancel = "Cancel"
    static let children = "Children"
    static let clearImage = "Clear image"
    static let collapse = "Collapse"
    static let copy = "Copy"
    static let dismissView = "Dismiss View"
    static let expand = "Expand"
    static let importImage = "Import image..."
    static let lostConnectionToView = "Lost connection to view"
    static let noElementInspector = "No Element Inspector"
    static let open = "Open"
    static let presentInspector = "Open Inspector..."
    static let preview = "Preview"
    static let searchViews = "Search Hierarchy"

    static func inspect(_ name: Any) -> String {
        "Inspect \(String(describing: name))..."
    }

    static func inspectableViews(_ viewCount: Int, in className: String) -> String {
        switch viewCount {
        case 1:
            return "\(viewCount) inspectable view in \(className)"

        default:
            return "\(viewCount) inspectable views in \(className)"
        }
    }

    static func allResults(count: Int, in elementName: String) -> String {
        switch count {
        case 1:
            return "\(count) Search result in \(elementName)"

        default:
            return "\(count) Search results in \(elementName)"
        }
    }

    static func emptyLayer(with description: String) -> String {
        description
    }

    static func highlight(_ something: String) -> String {
        "Highlight \(something)"
    }

    static func enable(_ something: String) -> String {
        "Enable \(something)"
    }

    static func select(_ something: String) -> String {
        "Select \(something)"
    }

    static func disable(_ something: String) -> String {
        "Disable \(something)"
    }

    static func hide(_ something: String) -> String {
        "Hide \(something)"
    }

    static func show(_ something: String) -> String {
        "Show \(something)"
    }

    static func highlighting(_ something: String) -> String {
        "Highlighting \(something)"
    }

    static func open(_ something: String) -> String {
        "Open \(something)"
    }

    static func copy(_ something: String) -> String {
        "Copy \(something)"
    }
}
