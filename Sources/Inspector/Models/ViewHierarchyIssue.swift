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

enum ViewHierarchyIssue: CustomStringConvertible {
    case emptyFrame
    case parentHasEmptyFrame
    case controlDisabled
    case interactionDisabled

    var description: String {
        switch self {
        case .emptyFrame:
            return "Frame is empty"
        case .parentHasEmptyFrame:
            return "Parent has empty frame"
        case .controlDisabled:
            return "Control disabled"
        case .interactionDisabled:
            return " User interaction disabled"
        }
    }

    static func issues(for reference: ViewHierarchyElement) -> [ViewHierarchyIssue] {
        var array = [ViewHierarchyIssue]()

        if reference.rootView?.frame.isEmpty == true {
            array.append(.emptyFrame)
        }
        if reference.rootView?.isUserInteractionEnabled == false {
            array.append(.interactionDisabled)
        }
        if (reference.rootView as? UIControl)?.isEnabled == false {
            array.append(.controlDisabled)
        }
        if reference.allParents.contains(where: { $0.issues.contains(.emptyFrame) }) {
            array.append(.parentHasEmptyFrame)
        }

        return array
    }
    
}
