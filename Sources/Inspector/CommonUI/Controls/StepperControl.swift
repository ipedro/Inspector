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
@_implementationOnly import UIKitOptions

final class StepperControl: BaseFormControl {
    // MARK: - Properties

    override var isEnabled: Bool {
        didSet {
            stepperControl.isEnabled = isEnabled
            updateState()
        }
    }

    var value: Double {
        get {
            stepperControl.value
        }
        set {
            stepperControl.value = newValue
            updateCounterLabel()
        }
    }

    var range: ClosedRange<Double> {
        get {
            stepperControl.minimumValue...stepperControl.maximumValue
        }
        set {
            stepperControl.minimumValue = newValue.lowerBound
            stepperControl.maximumValue = newValue.upperBound
        }
    }

    var stepValue: Double {
        get {
            stepperControl.stepValue
        }
        set {
            stepperControl.stepValue = newValue
        }
    }

    let isDecimalValue: Bool

    // MARK: - Components

    private lazy var stepperControl = UIStepper().then {
        $0.addTarget(self, action: #selector(step), for: .valueChanged)
    }

    private lazy var counterLabel = UILabel(
        .font(titleLabel.font!.withTraits(.traitMonoSpace)),
        .huggingPriority(.required, for: .horizontal)
    )

    // MARK: - Init

    init(title: String?, value: Double, range: ClosedRange<Double>, stepValue: Double, isDecimalValue: Bool) {
        self.isDecimalValue = isDecimalValue

        super.init(title: title)

        stepperControl.maximumValue = range.upperBound
        stepperControl.minimumValue = range.lowerBound
        stepperControl.stepValue = stepValue
        self.value = value
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        updateState()
        contentView.addArrangedSubviews(counterLabel, stepperControl)
    }

    @objc
    func step() {
        updateCounterLabel()

        sendActions(for: .valueChanged)
    }

    private func updateCounterLabel() {
        counterLabel.text = stepperControl.value.toString()
    }

    private func updateState() {
        stepperControl.alpha = isEnabled ? 1 : 0.5
        counterLabel.textColor = isEnabled ? colorStyle.textColor : colorStyle.secondaryTextColor
    }
}
