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

final class RectControl: BaseFormControl {
    var rect: CGRect {
        get {
            .init(
                x: CGFloat(xStepper.value),
                y: CGFloat(yStepper.value),
                width: CGFloat(widthStepper.value),
                height: CGFloat(heightStepper.value)
            )
        }
        set {
            xStepper.value = Double(newValue.origin.x)
            yStepper.value = Double(newValue.origin.y)
            widthStepper.value = Double(newValue.size.width)
            heightStepper.value = Double(newValue.size.height)
        }
    }

    override var isEnabled: Bool {
        didSet {
            xStepper.isEnabled = isEnabled
            yStepper.isEnabled = isEnabled
            widthStepper.isEnabled = isEnabled
            heightStepper.isEnabled = isEnabled
        }
    }

    override var title: String? {
        didSet {
            xStepper.title = "X".string(prepending: title)
            yStepper.title = "Y".string(prepending: title)
            widthStepper.title = "Width".string(prepending: title)
            heightStepper.title = "Height".string(prepending: title)
        }
    }

    private lazy var xStepper = Self.makeStepper(range: -Double.infinity...Double.infinity).then {
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    private lazy var yStepper = Self.makeStepper(range: -Double.infinity...Double.infinity).then {
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    private lazy var widthStepper = Self.makeStepper(range: 0...Double.infinity).then {
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    private lazy var heightStepper = Self.makeStepper(range: 0...Double.infinity).then {
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    convenience init(title: String?, rect: CGRect) {
        self.init(title: title, frame: .zero)
        self.rect = rect
    }

    override func setup() {
        super.setup()

        axis = .vertical

        applyTitleSectionStyle()

        contentView.axis = .vertical
        contentView.spacing = elementInspectorAppearance.verticalMargins
        contentView.addArrangedSubviews(
            xStepper,
            yStepper,
            SeparatorView(style: .soft),
            widthStepper,
            heightStepper
        )
    }

    @objc
    private func valueChanged() {
        sendActions(for: .valueChanged)
    }

    private static func makeStepper(range: ClosedRange<Double>) -> StepperControl {
        StepperControl(
            title: .none,
            value: .zero,
            range: range,
            stepValue: 1,
            isDecimalValue: true
        ).then {
            $0.containerView.directionalLayoutMargins.update(top: .zero, bottom: .zero)
            $0.isShowingSeparator = false
        }
    }
}
