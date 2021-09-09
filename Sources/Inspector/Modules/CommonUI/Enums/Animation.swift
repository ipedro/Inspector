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

enum Animation {
    case `in`, out

    private var scale: CGAffineTransform { CGAffineTransform(scaleX: 1.1, y: 1.04) }

    var damping: CGFloat { 0.84 }

    var velocity: CGFloat { .zero }

    var options: UIView.AnimationOptions { [.allowUserInteraction, .beginFromCurrentState] }

    var startTransform: CGAffineTransform {
        switch self {
        case .in:
            return scale

        case .out:
            return .identity
        }
    }

    var endTransform: CGAffineTransform {
            switch self {
        case .in:
            return .identity

        case .out:
            return scale
        }
    }
}

extension UIView {
    func animate(
        _ animation: Animation,
        duration: TimeInterval = ElementInspector.configuration.animationDuration,
        delay: TimeInterval = .zero,
        completion: ((Bool) -> Void)? = nil
    ) {
        transform = animation.startTransform

        Self.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: animation.damping,
            initialSpringVelocity: animation.velocity,
            options: animation.options,
            animations: { self.transform = animation.endTransform },
            completion: completion
        )
    }
}
