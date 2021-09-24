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

final class ElementInspectorFormLayoutConstraintView: BaseView, InspectorElementFormItemView {
    var title: String? {
        get { header.title }
        set { header.title = newValue }
    }

    var subtitle: String? {
        get { header.subtitle }
        set { header.subtitle = newValue }
    }

    var separatorStyle: InspectorElementFormItemSeparatorStyle {
        get { .none }
        set {}
    }

    static func makeItemView() -> InspectorElementFormItemView {
        ElementInspectorFormLayoutConstraintView()
    }

    private lazy var formView = ElementInspectorFormItemContentView(header: header).then {
        $0.separatorStyle = .none
    }

    var delegate: InspectorElementFormItemViewDelegate? {
        get { formView.delegate }
        set { formView.delegate = newValue }
    }

    var state: InspectorElementFormItemState {
        get { formView.state }
        set { formView.state = newValue }
    }

    private(set) lazy var header = SectionHeader(
        titleFont: .init(.footnote, .traitBold),
        subtitleFont: .footnote,
        margins: .init(vertical: ElementInspector.appearance.verticalMargins)
    )

    private lazy var cardView = BaseCardView().then {
        var insets = ElementInspector.appearance.directionalInsets
        insets.bottom = insets.leading
        insets.top = .zero

        $0.insets = insets
        $0.backgroundColor = colorStyle.accessoryControlBackgroundColor
        $0.contentView.addArrangedSubview(formView)
    }

    private var switchControl: UISwitch! {
        didSet {
            switchControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
            valueChanged()
        }
    }

    @objc private func valueChanged() {
        animate {
            if self.switchControl.isOn {
                self.cardView.borderColor = self.colorStyle.tintColor
                self.header.alpha = 1
                self.tintAdjustmentMode = .automatic
            }
            else {
                self.header.alpha = 0.5
                self.tintAdjustmentMode = .dimmed
                self.cardView.borderColor = self.colorStyle.quaternaryTextColor
            }
        }
    }

    override func setup() {
        super.setup()

        installView(contentView, priority: .required)
        contentView.addArrangedSubview(cardView)
    }

    func addFormViews(_ formViews: [UIView]) {
        // very hacky but nice ui benefit of moving the constraint active control to the header. shrug.
        formViews.forEach { view in
            guard
                let toggleControl = view as? ToggleControl,
                toggleControl.title == "Installed"
            else {
                return
            }

            switchControl = toggleControl.switchControl

            toggleControl.isHidden = true

            let switchContainerView = UIStackView().then {
                $0.addArrangedSubviews(switchControl)
                $0.isLayoutMarginsRelativeArrangement = true
                $0.directionalLayoutMargins = .init(trailing: ElementInspector.appearance.horizontalMargins)
            }

            formView.addHeaderArrangedSubviews(switchContainerView)
        }

        formView.addFormViews(formViews)
    }
}
