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

enum ElementInspectorPanelListState: Swift.CaseIterable, MenuContentProtocol {
    case allCollapsed, firstExpanded, mixed, allExpanded

    func next() -> Self? {
        switch self {
        case .allCollapsed:
            return .firstExpanded
        case .mixed, .firstExpanded:
            return .allExpanded
        case .allExpanded:
            return .none
        }
    }

    func previous() -> Self? {
        switch self {
        case .allCollapsed:
            return .none
        case .firstExpanded:
            return .allCollapsed
        case .mixed:
            return .allCollapsed
        case .allExpanded:
            return .firstExpanded
        }
    }

    // MARK: - MenuContentProtocol

    static func allCases(for element: ViewHierarchyElementReference) -> [ElementInspectorPanelListState] { [] }

    var title: String {
        switch self {
        case .allCollapsed:
            return "Collapse All"
        case .firstExpanded:
            return "Expand First"
        case .mixed:
            return "Mixed selection"
        case .allExpanded:
            return "Expand All"
        }
    }

    var image: UIImage? {
        switch self {
        case .allCollapsed:
            return .collapseMirroredSymbol
        case .firstExpanded:
            return .expandSymbol
        case .mixed:
            return nil
        case .allExpanded:
            return .expandSymbol
        }
    }
}
