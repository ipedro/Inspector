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

extension UILayoutPriority: CustomStringConvertible {
    var name: String {
        switch self {
        case .defaultHigh:
            return "High"
        case .defaultLow:
            return "Low"
        case .fittingSizeLevel:
            return "Fitting Size"
        case .required:
            return "Required"
        case .dragThatCanResizeScene:
            return "Drag That Can Resize Scene"
        case .sceneSizeStayPut:
            return "Scene Size Stay Put"
        case .dragThatCannotResizeScene:
            return "Drag That Can't Resize Scene"
        default:
            return rawValue.toString()
        }
    }

    var description: String { "\(name) (\(rawValue.toString()))" }
}
