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

// MARK: - UIControl.Event Extension

extension UIControl.Event {
    /// Event happens when the control's state is changed.
    static var stateChanged = UIControl.Event(rawValue: 1 << 24)
}

class BaseControl: UIControl, InternalViewProtocol, ElementInspectorAppearanceProviding {
    // MARK: - Properties

    private lazy var oldState: State = state

    open var animateOnTouch: Bool = false

    var defaultSpacing: CGFloat { elementInspectorAppearance.verticalMargins }

    // MARK: - Overrides

    /// A Boolean value indicating whether the control is in the enabled state.
    override open var isEnabled: Bool {
        willSet {
            oldState = state
        }
        didSet {
            checkState()
        }
    }

    /// A Boolean value indicating whether the control is in the selected state.
    override open var isSelected: Bool {
        willSet {
            oldState = state
        }
        didSet {
            checkState()
        }
    }

    /// A Boolean value indicating whether the control is in the highlighted state.
    override open var isHighlighted: Bool {
        willSet {
            oldState = state
        }
        didSet {
            checkState()
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setup() {}

    private(set) lazy var contentView = UIStackView.horizontal(
        .spacing(defaultSpacing)
    ).then {
        installView($0, priority: .required)
    }

    /// Tells this object that one or more new touches occurred in a view or window.
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldState = state

        super.touchesBegan(touches, with: event)

        checkState()

        if isEnabled, animateOnTouch {
            scale(.in, for: event)
        }
    }

    /// Tells the responder when one or more fingers are raised from a view or window.
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldState = state
        super.touchesEnded(touches, with: event)
        checkState()

        if isEnabled, animateOnTouch {
            scale(.out, for: event)
        }
    }

    /// Tells the responder when one or more touches associated with an event changed.
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldState = state
        super.touchesMoved(touches, with: event)
        checkState()
    }

    /// Tells the responder when a system event (such as a system alert) cancels a touch sequence.
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldState = state

        super.touchesCancelled(touches, with: event)

        checkState()

        if isEnabled, animateOnTouch {
            scale(.out, for: event)
        }
    }

    // MARK: - State Methods

    /// Gets called when the control state changes, default implementation does nothing.
    open func stateDidChange(from oldState: State, to newState: State) {}

    private func checkState() {
        guard state != oldState else { return }

        stateDidChange(from: oldState, to: state)
        sendActions(for: .stateChanged)
    }

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }

        // If there is no interactive parent on the view abort.
        guard let parent = hitView.nearestInteractiveParent else { return hitView }

        // Check if this view belongs to another interactive view (i.e. nested control)
        guard parent === self else { return parent }

        // If not we return self.
        //
        // By returning `self` we keep the control interactive without needing
        // to actively manage which subviews have `isUserInteractionEnabled` enabled or not.
        return self
    }
}

// MARK: - Helpers

private extension UIView {
    var hasInteraction: Bool {
        guard isUserInteractionEnabled else { return false }

        if let control = self as? UIControl {
            return control.isEnabled
        }

        if let gestureRecognizers = gestureRecognizers, !gestureRecognizers.isEmpty {
            return true
        }

        if !interactions.isEmpty {
            return true
        }

        return false
    }

    var nearestInteractiveParent: UIView? {
        var view: UIView? = self

        while view != nil {
            if view?.hasInteraction == true {
                return view
            }

            view = view?.superview
        }

        return nil
    }
}
