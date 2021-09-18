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

class StepperPairControl<FloatingPoint: BinaryFloatingPoint>: BaseFormControl {
    override var isEnabled: Bool {
        didSet {
            firstStepper.isEnabled = isEnabled
            secondStepper.isEnabled = isEnabled
        }
    }

    var firstSubtitle: String? {
        get { firstStepper.title }
        set { firstStepper.title = newValue }
    }

    var firstValue: FloatingPoint {
        get { FloatingPoint(firstStepper.value) }
        set { firstStepper.value = Double(newValue) }
    }

    var secondSubtitle: String? {
        get { secondStepper.title }
        set { secondStepper.title = newValue }
    }

    var secondValue: FloatingPoint {
        get { FloatingPoint(secondStepper.value) }
        set { secondStepper.value = Double(newValue) }
    }

    private lazy var firstStepper = StepperControl(
        title: .none,
        value: .zero,
        range: 0...Double.infinity,
        stepValue: 1,
        isDecimalValue: true
    ).then {
        $0.containerView.directionalLayoutMargins.update(bottom: .zero)
        $0.isShowingSeparator = false
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    private lazy var secondStepper = StepperControl(
        title: .none,
        value: .zero,
        range: 0...Double.infinity,
        stepValue: 1,
        isDecimalValue: true
    ).then {
        $0.containerView.directionalLayoutMargins.update(top: .zero, bottom: .zero)
        $0.isShowingSeparator = false
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    init(
        title: String? = nil,
        firstSubtitle: String? = nil,
        firstValue: FloatingPoint = .zero,
        secondSubtitle: String? = nil,
        secondValue: FloatingPoint = .zero,
        isEnabled: Bool = true,
        frame: CGRect = .zero
    ) {
        super.init(title: title, isEnabled: isEnabled, frame: frame)

        self.firstSubtitle = firstSubtitle
        self.firstValue = firstValue
        self.secondSubtitle = secondSubtitle
        self.secondValue = secondValue
    }

    override func setup() {
        super.setup()

        axis = .vertical

        contentView.axis = .vertical
        contentView.spacing = ElementInspector.appearance.verticalMargins
        contentView.addArrangedSubviews(firstStepper, secondStepper)
    }

    @objc
    private func valueChanged() {
        sendActions(for: .valueChanged)
    }
}
