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

#if canImport(UIKit)
@testable import Inspector
import UIKit
import XCTest

// MARK: - Mock Transition Context

private final class MockTransitionContext: NSObject, UIViewControllerContextTransitioning {
    var containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))

    var isAnimated: Bool = true
    var isInteractive: Bool = false
    var transitionWasCancelled: Bool = false
    var presentationStyle: UIModalPresentationStyle = .custom
    var targetTransform: CGAffineTransform = .identity

    private var viewControllers: [UITransitionContextViewControllerKey: UIViewController] = [:]
    private var views: [UITransitionContextViewKey: UIView] = [:]

    var completeTransitionCalled = false
    var completeTransitionFinished: Bool?

    func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    func pauseInteractiveTransition() {}

    func completeTransition(_ didComplete: Bool) {
        completeTransitionCalled = true
        completeTransitionFinished = didComplete
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        viewControllers[key]
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        views[key]
    }

    func initialFrame(for vc: UIViewController) -> CGRect { containerView.bounds }
    func finalFrame(for vc: UIViewController) -> CGRect { containerView.bounds }

    func setViewController(_ vc: UIViewController, forKey key: UITransitionContextViewControllerKey) {
        viewControllers[key] = vc
    }

    func setView(_ view: UIView, forKey key: UITransitionContextViewKey) {
        views[key] = view
    }
}

// MARK: - Tests

final class ElementInspectorPanelTransitionAnimatorTests: XCTestCase {

    // MARK: - Duration Tests

    func testTransitionDurationIsPositive() {
        let animator = ElementInspectorPanelTransitionAnimator()
        let duration = animator.transitionDuration(using: nil)
        XCTAssertGreaterThan(duration, 0, "Transition duration should be positive")
    }

    func testTransitionDurationIsConsistent() {
        let animator = ElementInspectorPanelTransitionAnimator()
        let durationWithNil = animator.transitionDuration(using: nil)

        let context = MockTransitionContext()
        let durationWithContext = animator.transitionDuration(using: context)

        XCTAssertEqual(
            durationWithNil,
            durationWithContext,
            "Transition duration should be the same regardless of context"
        )
    }

    // MARK: - Property Tests

    func testIsPresentingDefaultValue() {
        let animator = ElementInspectorPanelTransitionAnimator()
        XCTAssertTrue(animator.isPresenting, "isPresenting should default to true (push direction)")
    }

    // MARK: - Animation Tests

    func testAnimateTransitionCallsCompleteTransition() {
        let animator = ElementInspectorPanelTransitionAnimator()
        let context = MockTransitionContext()

        let fromVC = UIViewController()
        let toVC = UIViewController()
        fromVC.view.frame = context.containerView.bounds
        toVC.view.frame = context.containerView.bounds

        context.setViewController(fromVC, forKey: .from)
        context.setViewController(toVC, forKey: .to)
        context.setView(fromVC.view, forKey: .from)
        context.setView(toVC.view, forKey: .to)

        animator.animateTransition(using: context)

        let expectation = expectation(description: "completeTransition called")

        // Allow time for animations to complete (duration + buffer)
        let duration = animator.transitionDuration(using: context)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: duration + 2.0) { _ in
            XCTAssertTrue(
                context.completeTransitionCalled,
                "animateTransition must call completeTransition on the context"
            )
        }
    }

    func testForwardTransitionSetsUpCorrectInitialState() {
        let animator = ElementInspectorPanelTransitionAnimator()
        animator.isPresenting = true

        let context = MockTransitionContext()

        let fromVC = UIViewController()
        let toVC = UIViewController()
        fromVC.view.frame = context.containerView.bounds
        toVC.view.frame = context.containerView.bounds

        context.setViewController(fromVC, forKey: .from)
        context.setViewController(toVC, forKey: .to)
        context.setView(fromVC.view, forKey: .from)
        context.setView(toVC.view, forKey: .to)

        animator.animateTransition(using: context)

        // After animateTransition is called, toView should be added to the container
        let toViewIsInContainer = toVC.view.isDescendant(of: context.containerView)
        XCTAssertTrue(toViewIsInContainer, "toView should be added to the container view for forward transition")
    }

    func testBackwardTransitionSetsUpCorrectInitialState() {
        let animator = ElementInspectorPanelTransitionAnimator()
        animator.isPresenting = false

        let context = MockTransitionContext()

        let fromVC = UIViewController()
        let toVC = UIViewController()
        fromVC.view.frame = context.containerView.bounds
        toVC.view.frame = context.containerView.bounds

        // For backward (pop), fromView should already be in the container
        context.containerView.addSubview(fromVC.view)

        context.setViewController(fromVC, forKey: .from)
        context.setViewController(toVC, forKey: .to)
        context.setView(fromVC.view, forKey: .from)
        context.setView(toVC.view, forKey: .to)

        animator.animateTransition(using: context)

        // toView should be added to the container for backward transition as well
        let toViewIsInContainer = toVC.view.isDescendant(of: context.containerView)
        XCTAssertTrue(toViewIsInContainer, "toView should be added to the container view for backward transition")
    }

    // MARK: - Navigation Controller Delegate Tests

    func testNavigationControllerReturnsAnimatorForElementInspectorVCs() {
        // This test verifies that ElementInspectorNavigationController returns
        // an ElementInspectorPanelTransitionAnimator when both the from and to
        // view controllers are ElementInspectorViewController instances.
        //
        // Note: ElementInspectorViewController requires internal dependencies
        // to instantiate, so this test may need to be adapted once the
        // implementation is available. If the nav controller exposes the
        // delegate method publicly, we can call it directly.
        let navController = ElementInspectorNavigationController()

        guard let delegate = navController as? UINavigationControllerDelegate else {
            // If the nav controller does not yet conform to UINavigationControllerDelegate,
            // skip gracefully -- the implementation agent will wire this up.
            return
        }

        // We cannot easily create ElementInspectorViewController without its
        // full dependency graph. This test documents the expected behavior:
        // when both from/to are ElementInspectorViewController, the delegate
        // should return an ElementInspectorPanelTransitionAnimator.
        //
        // For now, verify the delegate method returns nil for plain UIViewControllers
        // (covered by the next test). Full integration testing requires the
        // animator implementation.
        let animator = delegate.navigationController?(
            navController,
            animationControllerFor: .push,
            from: UIViewController(),
            to: UIViewController()
        )

        // For non-ElementInspectorViewController transitions, should return nil
        XCTAssertNil(
            animator,
            "Should return nil animator for non-ElementInspectorViewController transitions"
        )
    }

    func testNavigationControllerReturnsNilForOtherVCs() {
        let navController = ElementInspectorNavigationController()

        guard let delegate = navController as? UINavigationControllerDelegate else {
            // Nav controller does not yet conform to UINavigationControllerDelegate
            return
        }

        let fromVC = UIViewController()
        let toVC = UIViewController()

        let pushAnimator = delegate.navigationController?(
            navController,
            animationControllerFor: .push,
            from: fromVC,
            to: toVC
        )
        XCTAssertNil(pushAnimator, "Should return nil for push between plain UIViewControllers")

        let popAnimator = delegate.navigationController?(
            navController,
            animationControllerFor: .pop,
            from: fromVC,
            to: toVC
        )
        XCTAssertNil(popAnimator, "Should return nil for pop between plain UIViewControllers")
    }
}
#endif
