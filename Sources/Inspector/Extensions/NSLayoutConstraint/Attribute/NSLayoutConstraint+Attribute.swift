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

extension NSLayoutConstraint.Attribute {
    var axis: NSLayoutConstraint.Axis? {
        switch self {
        case .left,
             .leftMargin,
             .right,
             .rightMargin,
             .leading,
             .leadingMargin,
             .trailing,
             .trailingMargin,
             .centerX,
             .centerXWithinMargins,
             .width:
            return .horizontal
        case .top,
             .topMargin,
             .bottom,
             .bottomMargin,
             .centerY,
             .centerYWithinMargins,
             .lastBaseline,
             .firstBaseline,
             .height:
            return .vertical
        case .notAnAttribute:
            return nil
        @unknown default:
            return nil
        }
    }

    var displayName: String? {
        switch self {
        case .left,
             .leftMargin:
            return "Left Space"
        case .right,
             .rightMargin:
            return "Right Space"
        case .top,
             .topMargin:
            return "Top Space"
        case .bottom,
             .bottomMargin:
            return "Bottom Space"
        case .leading,
             .leadingMargin:
            return "Leading Space"
        case .trailing,
             .trailingMargin:
            return "Trailing Space"
        case .width:
            return "Width"
        case .height:
            return "Height"
        case .centerX,
             .centerXWithinMargins:
            return "Align Center X"
        case .centerY,
             .centerYWithinMargins:
            return "Align Center Y"
        case .lastBaseline:
            return "Last Baseline"
        case .firstBaseline:
            return "First Baseline"
        case .notAnAttribute:
            return nil
        @unknown default:
            return nil
        }
    }

    var isRelativeToMargin: Bool {
        switch self {
        case .leftMargin,
             .rightMargin,
             .topMargin,
             .bottomMargin,
             .leadingMargin,
             .trailingMargin,
             .centerXWithinMargins,
             .centerYWithinMargins:
            return true
        default:
            return false
        }
    }
}