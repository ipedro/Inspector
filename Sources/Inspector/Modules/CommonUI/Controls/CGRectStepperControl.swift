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

final class CGRectStepperControl: BaseFormControl {
    var rect: CGRect {
        get {
            CGRect(origin: originStepper.point, size: sizeStepper.size)
        }
        set {
            originStepper.point = newValue.origin
            sizeStepper.size = newValue.size
        }
    }

    override var isEnabled: Bool {
        didSet {
            originStepper.isEnabled = isEnabled
            sizeStepper.isEnabled = isEnabled
        }
    }

    override var title: String? {
        get { _title }
        set { _title = newValue }
    }

    private var _title: String? {
        didSet {
            originStepper.title = _title
            sizeStepper.title = _title
        }
    }

    private lazy var originStepper = CGPointStepperControl(title: title, point: .zero).then {
        $0.containerView.directionalLayoutMargins.update(bottom: .zero)
        $0.isShowingSeparator = false
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    private lazy var sizeStepper = CGSizeStepperControl(title: title, size: .zero).then {
        $0.containerView.directionalLayoutMargins.update(top: .zero, bottom: .zero)
        $0.isShowingSeparator = false
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    convenience init(title: String?, rect: CGRect? = nil) {
        self.init(title: .none, frame: .zero)
        self.rect = rect ?? .zero
        self.title = title
    }

    override func setup() {
        super.setup()

        axis = .vertical

        contentView.axis = .vertical
        contentView.spacing = ElementInspector.appearance.verticalMargins
        contentView.addArrangedSubviews(originStepper, sizeStepper)
    }

    @objc
    private func valueChanged() {
        sendActions(for: .valueChanged)
    }
}
