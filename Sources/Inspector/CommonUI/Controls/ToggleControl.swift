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

protocol ToggleControlDelegate: AnyObject {
    func toggleControl(_ toggleControl: ToggleControl, didChangeValueTo isOn: Bool)
}

final class ToggleControl: BaseFormControl {
    // MARK: - Properties

    weak var delegate: ToggleControlDelegate?

    var isOn: Bool {
        get {
            switchControl.isOn
        }
        set {
            setOn(newValue, animated: false)
        }
    }

    override var isEnabled: Bool {
        didSet {
            switchControl.isEnabled = isEnabled

            guard isEnabled else {
                return
            }

            updateViews()
        }
    }

    private(set) lazy var switchControl = StyledSwitch().then {
        $0.addTarget(self, action: #selector(toggleOn), for: .valueChanged)
    }

    private lazy var switchContainer = UIStackView().then {
        $0.addArrangedSubview(switchControl)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.directionalLayoutMargins = .init(trailing: 2)
    }

    // MARK: - Init

    init(title: String?, isOn: Bool) {
        super.init(title: title)

        self.isOn = isOn
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        contentView.addArrangedSubview(switchContainer)

        updateViews()
    }

    func setOn(_ on: Bool, animated: Bool) {
        switchControl.setOn(on, animated: animated)
        updateViews()
        delegate?.toggleControl(self, didChangeValueTo: switchControl.isOn)
    }

    @objc
    func toggleOn() {
        updateViews()
        sendActions(for: .valueChanged)
        delegate?.toggleControl(self, didChangeValueTo: switchControl.isOn)
    }

    func updateViews() {
        titleLabel.font = isOn ? titleFont.withTraits(.traitBold) : titleFont
    }
}

extension ToggleControl {
    final class StyledSwitch: UISwitch {
        override var isOn: Bool {
            didSet {
                updateThumbColor()
            }
        }

        override func setOn(_ on: Bool, animated: Bool) {
            super.setOn(on, animated: animated)
            updateThumbColor()
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            tintColor = colorStyle.accessoryControlBackgroundColor
            onTintColor = colorStyle.tintColor

            switch colorStyle {
            case .dark:
                thumbTintColor = UIColor.white.withAlphaComponent(colorStyle.disabledAlpha)
            case .light:
                thumbTintColor = UIColor.white.withAlphaComponent(colorStyle.disabledAlpha * 2)
            }

            addTarget(self, action: #selector(updateThumbColor), for: .valueChanged)

            updateThumbColor()
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

            guard
                #available(iOS 13.0, *),
                traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
            else {
                return
            }

            updateThumbColor()
        }

        @objc func updateThumbColor() {
            switch (colorStyle, isOn) {
            case (.dark, true):
                thumbTintColor = colorStyle.quaternaryTextColor
            case (.dark, false):
                thumbTintColor = colorStyle.tertiaryTextColor
            case (.light, true):
                thumbTintColor = UIColor.white.withAlphaComponent(colorStyle.disabledAlpha * 2)
            case (.light, false):
                thumbTintColor = UIColor.white.withAlphaComponent(colorStyle.disabledAlpha * 4)
            }
        }
    }
}
