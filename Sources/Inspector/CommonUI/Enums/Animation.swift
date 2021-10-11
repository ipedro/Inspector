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

extension TimeInterval {
    static let veryShort: TimeInterval = average / 4
    static let short: TimeInterval = average / 2
    static let average: TimeInterval = CATransaction.animationDuration()
    static let long: TimeInterval = average * 2
    static let veryLong: TimeInterval = average * 3
}

enum Animation {
    static let defaultDamping: CGFloat = 0.825
    static let defaultOptions: UIView.AnimationOptions = [.allowUserInteraction, .beginFromCurrentState]
    static let defaultVelocity: CGFloat = .zero

    case `in`, out

    var damping: CGFloat { Self.defaultDamping }

    var velocity: CGFloat { Self.defaultVelocity }

    var options: UIView.AnimationOptions { [.allowUserInteraction, .beginFromCurrentState] }

    var transform: CGAffineTransform {
        switch self {
        case .in:
            return CGAffineTransform(scaleX: 0.9, y: 0.96)

        case .out:
            return .identity
        }
    }
}

extension UIView {
    func animate(
        from fromAnimation: Animation,
        to toAnimation: Animation,
        duration: TimeInterval = .average,
        delay: TimeInterval = .zero,
        completion: ((Bool) -> Void)? = nil
    ) {
        transform = fromAnimation.transform

        animate(toAnimation, duration: duration, delay: delay, completion: completion)
    }

    func animate(
        _ animation: Animation,
        duration: TimeInterval = .average,
        delay: TimeInterval = .zero,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: animation.damping,
            initialSpringVelocity: animation.velocity,
            options: animation.options,
            animations: { self.transform = animation.transform },
            completion: completion
        )
    }
}

extension NSObject {
    func animate(
        withDuration duration: TimeInterval = .average,
        delay: TimeInterval = .zero,
        damping: CGFloat = Animation.defaultDamping,
        options: UIView.AnimationOptions = Animation.defaultOptions,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: Animation.defaultVelocity,
            options: options,
            animations: animations,
            completion: completion
        )
    }
}
