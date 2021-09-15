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

final class CGPointStepperControl: BaseFormControl {
    var point: CGPoint {
        get {
            CGPoint(x: xStepper.value, y: yStepper.value)
        }
        set {
            xStepper.value = Double(newValue.x)
            yStepper.value = Double(newValue.y)
        }
    }

    override var isEnabled: Bool {
        didSet {
            xStepper.isEnabled = isEnabled
            yStepper.isEnabled = isEnabled
        }
    }

    private lazy var xStepper = StepperControl(
        title: "X",
        value: .zero,
        range: -Double.infinity...Double.infinity,
        stepValue: 1,
        isDecimalValue: true
    ).then {
        $0.isShowingSeparator = false
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    private lazy var yStepper = StepperControl(
        title: "Y",
        value: .zero,
        range: -Double.infinity...Double.infinity,
        stepValue: 1,
        isDecimalValue: true
    ).then {
        $0.isShowingSeparator = false
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    convenience init(title: String?, point: CGPoint?) {
        self.init(title: title, frame: .zero)
        self.point = point ?? .zero
    }

    override func setup() {
        super.setup()

        axis = .vertical
        contentView.axis = .horizontal
        contentView.distribution = .fillEqually
        contentView.addArrangedSubviews(xStepper, yStepper)
    }

    @objc
    private func valueChanged() {
        sendActions(for: .valueChanged)
    }
}
