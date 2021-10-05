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

private extension ElementInspectorSlidingPanelAnimator {
    final class BackgroundGestureView: BaseView {

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let result = super.hitTest(point, with: event)

            guard result === self else { return result }

            guard let rootView = window?.rootViewController?.view else { return nil }

            let localPoint = convert(point, to: rootView)

            let rootResult = rootView.hitTest(localPoint, with: event)

            return rootResult
        }

    }

    final class DropShadowView: BaseView {
        override func setup() {
            layer.shadowRadius = ElementInspector.appearance.elementInspectorCornerRadius
            layer.shadowColor = UIColor(white: 0, alpha: 0.5).cgColor
        }

        override func layoutSubviews() {
            super.layoutSubviews()
        }
    }
}

final class ElementInspectorSlidingPanelAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = .veryLong

    var isPresenting: Bool = true
    
    private var isObservingSize = false

    private lazy var backgroundGestureView = BackgroundGestureView().then {
        $0.addObserver(self, forKeyPath: .bounds, options: .new, context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let containerView = shadowView.superview else { return }

        self.shadowView.frame = self.topLeftMargins(of: containerView)
    }

    deinit {
        backgroundGestureView.removeObserver(self, forKeyPath: .bounds, context: nil)
    }

    private lazy var shadowView = DropShadowView()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            pushTransition(using: transitionContext)
        }
        else {
            popTransition(using: transitionContext)
        }
    }

    private func frameToTheRight(of containerView: UIView) -> CGRect {
        var frame = containerView.bounds.inset(by: ElementInspector.appearance.directionalInsets.edgeInsets())
        frame.size.width = ElementInspector.configuration.panelPreferredCompressedSize.width
        frame.size.height = min(frame.size.height,  ElementInspector.configuration.panelSidePresentationMinimumContainerSize.height)
        frame.origin.x = containerView.bounds.maxX

        return frame
    }

    private func topLeftMargins(of containerView: UIView) -> CGRect {
        var frame = containerView.bounds.inset(by: ElementInspector.appearance.directionalInsets.edgeInsets())
        frame.size.width = ElementInspector.configuration.panelPreferredCompressedSize.width
        frame.size.height = min(frame.size.height,  ElementInspector.configuration.panelSidePresentationMinimumContainerSize.height)
        frame.origin.x = containerView.bounds.maxX - frame.width
        frame = frame.inset(by: ElementInspector.appearance.directionalInsets.edgeInsets())

        return frame
    }

    private func pushTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = transitionContext.view(forKey: .to) else { return }

        let toStartFrame = frameToTheRight(of: containerView)

        shadowView.installView(toView, priority: .required)
        containerView.addSubview(shadowView)
        shadowView.frame = toStartFrame
        shadowView.layer.shadowOpacity = 0

        let toFinalFrame = topLeftMargins(of: containerView)

        toView.layer.cornerRadius = ElementInspector.appearance.elementInspectorCornerRadius
        if #available(iOS 13.0, *) {
            toView.layer.cornerCurve = .continuous
        }

        backgroundGestureView.alpha = 0
        containerView.installView(backgroundGestureView, position: .behind)

        animate(withDuration: duration) {
            self.shadowView.frame = toFinalFrame
            self.shadowView.layer.shadowOpacity = 1
            self.backgroundGestureView.alpha = 1
        } completion: { finish in
            transitionContext.completeTransition(finish)
        }
    }

    private func popTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }

        fromView.layer.cornerRadius = .zero

        var fromFinalFrame = shadowView.frame
        fromFinalFrame.origin.x = transitionContext.containerView.bounds.maxX

        animate(withDuration: duration) {
            self.shadowView.frame = fromFinalFrame
            self.shadowView.layer.shadowOpacity = 0
            self.backgroundGestureView.alpha = 0
        } completion: { finish in
            if finish {
                self.backgroundGestureView.removeFromSuperview()
            }
            else {
                self.backgroundGestureView.alpha = 1
            }
            transitionContext.completeTransition(finish)
        }
    }

}

private extension String {
    static let bounds = "bounds"
}
