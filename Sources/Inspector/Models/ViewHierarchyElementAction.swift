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

enum ViewHierarchyElementAction: MenuContentProtocol {
    case layer(action: ViewHierarchyLayerAction)
    case inspect(preferredPanel: ElementInspectorPanel)
    case copy(info: ViewHierarchyInformation)

    var title: String {
        switch self {
        case let .layer(action):
            return action.title

        case let .inspect(preferredPanel):
            return preferredPanel.title

        case let .copy(content):
            return content.title
        }
    }

    var isOn: Bool {
        switch self {
        case let .layer(action):
            switch action {
            case .hideHighlight: return true
            case .showHighlight: return false
            }
        case .inspect: return false
        case .copy: return false
        }
    }

    var image: UIImage? {
        switch self {
        case let .layer(action):
            return action.image
        case let .inspect(preferredPanel):
            return preferredPanel.image
        case let .copy(content):
            return content.image
        }
    }

    static func allCases(for element: ViewHierarchyElementReference) -> [ViewHierarchyElementAction] {
        var actions = [ViewHierarchyElementAction]()

        for action in ViewHierarchyLayerAction.allCases(for: element) {
            actions.append(.layer(action: action))
        }

        for panel in ElementInspectorPanel.allCases(for: element) {
            actions.append(.inspect(preferredPanel: panel))
        }

        for content in ViewHierarchyInformation.allCases(for: element) {
            actions.append(.copy(info: content))
        }

        return actions
    }

    struct ElementActionGroup {
        let title: String
        let image: UIImage?
        let inline: Bool
        let actions: [ViewHierarchyElementAction]
    }

    static func actionGroups(for element: ViewHierarchyElementReference) -> [ElementActionGroup] {
        [
            .init(
                title: "",
                image: .none,
                inline: true,
                actions: ElementInspectorPanel.allCases(for: element).map { .inspect(preferredPanel: $0) }
            ),
            .init(
                title: "",
                image: .layerAction,
                inline: true,
                actions: ViewHierarchyLayerAction.allCases(for: element).map { .layer(action: $0) }
            ),
            .init(
                title: "Copy",
                image: .copySymbol,
                inline: false,
                actions: ViewHierarchyInformation.allCases(for: element).map { .copy(info: $0) }
            )
        ]
        .filter { !$0.actions.isEmpty }
    }
}
