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

final class CGSizeStepperControl: BaseFormControl {
    var size: CGSize {
        get {
            CGSize(width: widthStepper.value, height: heightStepper.value)
        }
        set {
            widthStepper.value = Double(newValue.width)
            heightStepper.value = Double(newValue.height)
        }
    }

    override var isEnabled: Bool {
        didSet {
            widthStepper.isEnabled = isEnabled
            heightStepper.isEnabled = isEnabled
        }
    }

    private lazy var widthStepper = StepperControl(
        title: "Width",
        value: .zero,
        range: 0...Double.infinity,
        stepValue: 1,
        isDecimalValue: true
    ).then {
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    private lazy var heightStepper = StepperControl(
        title: "Height",
        value: .zero,
        range: 0...Double.infinity,
        stepValue: 1,
        isDecimalValue: true
    ).then {
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    convenience init(title: String?, size: CGSize?) {
        self.init(title: title, frame: .zero)
        self.size = size ?? .zero
    }

    override func setup() {
        super.setup()

        axis = .vertical
        contentView.distribution = .fillEqually
        contentView.axis = .vertical
        contentView.addArrangedSubviews(widthStepper, heightStepper)
    }

    @objc
    private func valueChanged() {
        sendActions(for: .valueChanged)
    }
}
