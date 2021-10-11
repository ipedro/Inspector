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

final class InspectorElementLayoutConstraintSectionView: BaseView {
    var title: String? {
        get { header.title }
        set { header.title = newValue }
    }

    var subtitle: String? {
        get { header.subtitle }
        set { header.subtitle = newValue }
    }

    var separatorStyle: InspectorElementItemSeparatorStyle {
        get { .none }
        set {}
    }

    private lazy var formView = InspectorElementSectionFormView(header: header, state: state).then {
        $0.separatorStyle = .none
    }

    var delegate: InspectorElementFormItemViewDelegate? {
        get { formView.delegate }
        set { formView.delegate = newValue }
    }

    var state: InspectorElementSectionState {
        didSet {
            formView.state = state
        }
    }

    private(set) lazy var header = SectionHeader(
        titleFont: .init(.footnote, .traitBold),
        subtitleFont: .caption1,
        margins: .init(vertical: ElementInspector.appearance.verticalMargins)
    )

    private lazy var cardView = BaseCardView().then {
        var insets = ElementInspector.appearance.directionalInsets
        insets.bottom = insets.leading
        insets.top = .zero

        $0.insets = insets
        $0.cornerRadius = ElementInspector.appearance.elementInspectorCornerRadius
        $0.contentMargins = .zero
        $0.backgroundColor = colorStyle.layoutConstraintsCardBackgroundColor
        $0.contentView.addArrangedSubview(formView)
    }

    private var isConstraintActive = true {
        didSet {
            if isConstraintActive {
                self.header.alpha = 1
                self.tintAdjustmentMode = .automatic

                self.cardView.borderColor = self.colorStyle.tintColor
                self.cardView.backgroundColor = self.colorStyle.layoutConstraintsCardBackgroundColor
            }
            else {
                self.header.alpha = 0.5
                self.tintAdjustmentMode = .dimmed

                self.cardView.borderColor = self.colorStyle.quaternaryTextColor
                self.cardView.backgroundColor = self.colorStyle.layoutConstraintsCardInactiveBackgroundColor
            }
        }
    }

    init(state: InspectorElementSectionState, frame: CGRect = .zero) {
        self.state = state
        super.init(frame: frame)
    }

    override func setup() {
        super.setup()

        contentView.addArrangedSubview(cardView)
    }
}

// MARK: - InspectorElementSectionView

extension InspectorElementLayoutConstraintSectionView: InspectorElementSectionView {
    static func makeItemView(with inititalState: InspectorElementSectionState) -> InspectorElementSectionView {
        InspectorElementLayoutConstraintSectionView(state: inititalState)
    }

    func addTitleAccessoryView(_ titleAccessoryView: UIView?) {
        formView.addTitleAccessoryView(titleAccessoryView)

        guard let toggleControl = titleAccessoryView as? ToggleControl else {
            return
        }

        toggleControl.delegate = self
        isConstraintActive = toggleControl.isOn
    }

    func addFormViews(_ formViews: [UIView]) {
        formView.addFormViews(formViews)
    }
}

// MARK: - ToggleControlDelegate

extension InspectorElementLayoutConstraintSectionView: ToggleControlDelegate {
    func toggleControl(_ toggleControl: ToggleControl, didChangeValueTo isOn: Bool) {
        animate {
            self.isConstraintActive = toggleControl.isOn
        }
    }
}
