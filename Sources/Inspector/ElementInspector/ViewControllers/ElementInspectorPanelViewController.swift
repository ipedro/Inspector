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

class ElementInspectorPanelViewController: UIViewController {
    // MARK: - Layout

    open var panelScrollView: UIScrollView? { nil }

    private var needsLayout = true

    var isCompactVerticalPresentation: Bool = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard needsLayout else { return }

        needsLayout = false

        updatePreferredContentSize()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        updateVerticalPresentationState()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateVerticalPresentationState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateVerticalPresentationState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateVerticalPresentationState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateVerticalPresentationState()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateVerticalPresentationState()
    }

    @objc
    private func updateVerticalPresentationState() {
        guard let parent = parent else { return }

        let newValue: Bool = {
            if let popover = parent.popoverPresentationController {
                #if swift(>=5.5)
                if #available(iOS 15.0, *) {
                    return popover.adaptiveSheetPresentationController.selectedDetentIdentifier != .large
                }
                #endif

                _ = popover

                return true
            }

            return false
        }()

        guard newValue != isCompactVerticalPresentation else { return }

        isCompactVerticalPresentation = newValue
    }

    @objc
    private func updatePreferredContentSize() {
        guard modalPresentationStyle == .popover else { return }

        preferredContentSize = calculatePreferredContentSize()
    }

    func calculatePreferredContentSize() -> CGSize {
        if isViewLoaded {
            return view.systemLayoutSizeFitting(
                ElementInspector.appearance.panelPreferredCompressedSize,
                withHorizontalFittingPriority: .defaultHigh,
                verticalFittingPriority: .fittingSizeLevel
            )
        }
        else {
            return .zero
        }
    }
}
