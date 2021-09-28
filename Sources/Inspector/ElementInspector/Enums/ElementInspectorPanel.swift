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

enum ElementInspectorPanel: Swift.CaseIterable, Hashable {
    typealias RawValue = ViewHierarchyAction

    case preview
    case attributes
    case size
    case children

    static func panels(for reference: ViewHierarchyReference) -> [ElementInspectorPanel] {
        let actions = ViewHierarchyAction.actions(for: reference)
        return panels(for: actions)
    }
    
    static func panels(for actions: [ViewHierarchyAction]) -> [ElementInspectorPanel] {
        actions.compactMap { .init(rawValue: $0) }
    }

    var title: String {
        rawValue.title
    }

    var image: UIImage? {
        rawValue.image
    }
}

extension ElementInspectorPanel: RawRepresentable {
    var rawValue: ViewHierarchyAction {
        switch self {
        case .children:
            return .children
        case .preview:
            return .preview
        case .size:
            return .size
        case .attributes:
            return .attributes
        }
    }

    init?(rawValue: ViewHierarchyAction) {
        guard let panel = Self.panel(for: rawValue) else { return nil }
        self = panel
    }

    private static func panel(for action: ViewHierarchyAction) -> ElementInspectorPanel? {
        switch action {
        case .children:
            return .children
        case .preview:
            return .preview
        case .size:
            return .size
        case .attributes:
            return .attributes
        case .hideHightlight, .showHighlight, .tap:
            return nil
        }
    }
}
