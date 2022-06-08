//  Copyright (c) 2022 Pedro Almeida
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

final class AdaptiveModalPresenter: NSObject {
    enum Detent {
        case medium, large
    }

    private let presentationStyleProvider: (UIPresentationController, UITraitCollection) -> UIModalPresentationStyle
    private let onChangeSelectedDetentHandler: (Detent?) -> Void
    private let onDismissHandler: (UIPresentationController) -> Void

    init(
        presentationStyle: @escaping (UIPresentationController, UITraitCollection) -> UIModalPresentationStyle,
        onChangeSelectedDetent: @escaping (Detent?) -> Void,
        onDismiss: @escaping ((UIPresentationController) -> Void)
    ) {
        onChangeSelectedDetentHandler = onChangeSelectedDetent
        presentationStyleProvider = presentationStyle
        onDismissHandler = onDismiss
    }
}

extension AdaptiveModalPresenter: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        presentationStyleProvider(controller, traitCollection)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismissHandler(presentationController)
    }
}

extension AdaptiveModalPresenter: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        onDismissHandler(popoverPresentationController)
    }
}

#if swift(>=5.5)
@available(iOS 15.0, *)
extension AdaptiveModalPresenter: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        onChangeSelectedDetentHandler(
            sheetPresentationController.selectedDetentIdentifier == .medium ? .medium : .large
        )
    }
}
#endif
