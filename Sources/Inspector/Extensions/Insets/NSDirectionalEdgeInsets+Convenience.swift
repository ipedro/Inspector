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

extension NSDirectionalEdgeInsets {
    @inlinable
    @_disfavoredOverload
    init<T>(
        top: T? = nil,
        leading: T? = nil,
        bottom: T? = nil,
        trailing: T? = nil
    ) where T: BinaryFloatingPoint {
        self.init()
        self.top = CGFloat(top ?? .zero)
        self.leading = CGFloat(leading ?? .zero)
        self.bottom = CGFloat(bottom ?? .zero)
        self.trailing = CGFloat(trailing ?? .zero)
    }

    @inlinable
    init<T>(_ insets: T) where T: BinaryFloatingPoint {
        self.init(top: insets, leading: insets, bottom: insets, trailing: insets)
    }

    @inlinable
    @_disfavoredOverload
    init<T>(horizontal: T? = nil, vertical: T? = nil) where T: BinaryFloatingPoint {
        self.init(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }

    @inlinable
    var verticalInsets: CGFloat { top + bottom }

    @inlinable
    var horizontalInsets: CGFloat { leading + trailing }

    @inlinable
    func edgeInsets() -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
    }
}
