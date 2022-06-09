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

protocol ElementInspectorNavigationControllerDismissDelegate: AnyObject {
    func elementInspectorNavigationControllerDidFinish(_ navigationController: ElementInspectorNavigationController)
}

class ElementInspectorNavigationController: UINavigationController, InternalViewProtocol, ElementInspectorAppearanceProviding {
    weak var dismissDelegate: ElementInspectorNavigationControllerDismissDelegate?

    var shouldAdaptModalPresentation: Bool = true {
        didSet {
            if shouldAdaptModalPresentation {
                if popoverPresentationController?.delegate === self {
                    popoverPresentationController?.delegate = nil
                }
                return
            }

            popoverPresentationController?.delegate = self
        }
    }

    override func loadView() {
        super.loadView()
        let container = BaseView()
        container.installView(view)
        container.frame = view.frame
        view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = colorStyle.textColor

        view.installView(blurView, position: .behind)

        navigationBar.barTintColor = colorStyle.highlightBackgroundColor

        navigationBar.tintColor = view.tintColor

        navigationBar.directionalLayoutMargins.update(
            leading: elementInspectorAppearance.horizontalMargins,
            trailing: elementInspectorAppearance.horizontalMargins
        )

        navigationBar.largeTitleTextAttributes = [
            .font: elementInspectorAppearance.titleFont(forRelativeDepth: .zero),
            .foregroundColor: colorStyle.textColor
        ]

        addKeyCommand(dismissModalKeyCommand(action: #selector(finish)))

        becomeFirstResponder()
    }

    private(set) lazy var blurView = UIVisualEffectView(
        effect: UIBlurEffect(style: colorStyle.blurStyle)
    )

    override var canBecomeFirstResponder: Bool { true }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        // Async here is preventing weird popover behavior.
        DispatchQueue.main.async {
            self.preferredContentSize = container.preferredContentSize
        }
    }

    @objc private func finish() {
        dismissDelegate?.elementInspectorNavigationControllerDidFinish(self)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ElementInspectorNavigationController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle { .none }
}
