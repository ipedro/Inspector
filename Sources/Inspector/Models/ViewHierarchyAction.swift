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

enum ViewHierarchyAction: MenuContentProtocol {
    case layer(ViewHierarchyLayerAction)
    case inspect(preferredPanel: ElementInspectorPanel?)
    case copy(ViewHierarchyInformation)

    var title: String {
        switch self {
        case let .layer(action):
            return action.title

        case let .inspect(preferredPanel):
            return preferredPanel?.title ?? "Open"

        case let .copy(content):
            return content.title
        }
    }

    var image: UIImage? {
        switch self {
        case let .layer(action):
            return action.image

        case let .inspect(preferredPanel):
            return preferredPanel?.image

        case let .copy(content):
            return content.image
        }
    }

    static func allCases(for reference: ViewHierarchyElement) -> [ViewHierarchyAction] {
        var actions = [ViewHierarchyAction]()

        for action in ViewHierarchyLayerAction.allCases(for: reference) {
            actions.append(.layer(action))
        }

        for panel in ElementInspectorPanel.allCases(for: reference) {
            actions.append(.inspect(preferredPanel: panel))
        }

        for content in ViewHierarchyInformation.allCases(for: reference) {
            actions.append(.copy(content))
        }

        return actions
    }

    static func groupedCases(for reference: ViewHierarchyElement) -> [[ViewHierarchyAction]] {
        [
            ViewHierarchyLayerAction.allCases(for: reference).map { .layer($0) },
            ElementInspectorPanel.allCases(for: reference).map { .inspect(preferredPanel: $0) },
            ViewHierarchyInformation.allCases(for: reference).map { .copy($0) }
        ]
    }
}
