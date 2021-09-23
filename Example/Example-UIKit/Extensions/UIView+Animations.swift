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

extension UIView {
    enum AnimationMode: CGFloat {
        case slowly = 0.6
        case `default` = 0.3
        case quickly = 0.2

        fileprivate var duration: TimeInterval { TimeInterval(rawValue) }

        fileprivate var delay: TimeInterval { .zero }

        fileprivate var springWithDamping: CGFloat { 1 - (rawValue / 3) }

        fileprivate var springVelocity: CGFloat { rawValue * 10 }

        fileprivate var options: AnimationOptions { [.beginFromCurrentState, .allowUserInteraction] }
    }

    static func animate(_ mode: AnimationMode = .default, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        animate(
            withDuration: mode.duration,
            delay: mode.delay,
            usingSpringWithDamping: mode.springWithDamping,
            initialSpringVelocity: mode.springVelocity,
            options: mode.options,
            animations: animations,
            completion: completion
        )
    }
}
