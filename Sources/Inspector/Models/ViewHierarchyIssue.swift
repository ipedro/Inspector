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

enum ViewHierarchyIssue: CustomStringConvertible, Hashable {
    case emptyFrame
    case parentHasEmptyFrame
    case controlDisabled
    case interactionDisabled
    case lostConnection
    case iOS15_emptyNavigationBarScrollEdgeAppearance

    var description: String {
        switch self {
        case .lostConnection:
            return Texts.lostConnectionToView
        case .emptyFrame:
            return "Frame is empty"
        case .parentHasEmptyFrame:
            return "Parent has empty frame"
        case .controlDisabled:
            return "Control disabled"
        case .interactionDisabled:
            return " User interaction disabled"
        case .iOS15_emptyNavigationBarScrollEdgeAppearance:
            return "Starting in iOS 15 the default behavior produces a transparent background when not scrolled.\n\nSet UINavigationBar.scrollEdgeAppearance to get the legacy behavior."
        }
    }

    static func issues(for view: UIView) -> [ViewHierarchyIssue] {
        var array = [ViewHierarchyIssue]()

        if view.frame.isEmpty == true {
            array.append(.emptyFrame)
        }
        if view.isUserInteractionEnabled == false {
            array.append(.interactionDisabled)
        }
        if (view as? UIControl)?.isEnabled == false {
            array.append(.controlDisabled)
        }
        
        #if swift(>=5.5)
        guard #available(iOS 15.0, *) else { return array }

        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithDefaultBackground()

        if
            let navigationBar = view as? UINavigationBar,
            navigationBar.scrollEdgeAppearance == nil,
            navigationBar.standardAppearance.backgroundColor != defaultAppearance.backgroundColor,
            navigationBar.standardAppearance.backgroundEffect?.style != defaultAppearance.backgroundEffect?.style
        {
            array.append(.iOS15_emptyNavigationBarScrollEdgeAppearance)
        }
        #endif

        return array
    }
    
}
