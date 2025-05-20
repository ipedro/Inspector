//  Copyright (c) 2025 Pedro Almeida
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

extension UIEdgeInsets {
    @inlinable
    @_disfavoredOverload
    init<T>(
        top: T? = nil,
        left: T? = nil,
        bottom: T? = nil,
        right: T? = nil
    ) where T: BinaryFloatingPoint {
        self.init()
        self.top = CGFloat(top ?? .zero)
        self.left = CGFloat(left ?? .zero)
        self.bottom = CGFloat(bottom ?? .zero)
        self.right = CGFloat(right ?? .zero)
    }

    @inlinable
    init(_ insets: some BinaryFloatingPoint) {
        self.init(top: insets, left: insets, bottom: insets, right: insets)
    }

    @inlinable
    @_disfavoredOverload
    init<T>(horizontal: T? = nil, vertical: T? = nil) where T: BinaryFloatingPoint {
        self.init(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }

    var verticalInsets: CGFloat { top + bottom }

    var horizontalInsets: CGFloat { left + right }

    func directionalEdgeInsets() -> NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }

    func rightToLeftDirectionalEdgeInsets() -> NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(top: top, leading: right, bottom: bottom, trailing: left)
    }
}
