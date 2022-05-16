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

final class InspectorElementKeyCommandSectionView: BaseView {
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
        set {  }
    }

    private lazy var formView = InspectorElementSectionFormView(header: header, state: state).then {
        $0.separatorStyle = .none
        $0.headerLayoutMargins.update(top: 4, bottom: 4)
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
        titleFont: .init(.callout, .traitBold),
        subtitleFont: .init(.footnote, .traitBold),
        margins: .init(vertical: elementInspectorAppearance.verticalMargins)
    )

    private lazy var cardView = BaseCardView().then {
        var insets = elementInspectorAppearance.directionalInsets
        insets.bottom = insets.leading
        insets.top = .zero

        $0.margins = .init(
            horizontal: elementInspectorAppearance.horizontalMargins,
            vertical: elementInspectorAppearance.verticalMargins / 2
        )
        $0.contentMargins = .zero
        $0.backgroundColor = colorStyle.cellHighlightBackgroundColor
        $0.contentView.addArrangedSubview(formView)

        formView.headerControl.layer.cornerRadius = $0.cornerRadius
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

extension InspectorElementKeyCommandSectionView: InspectorElementSectionView {
    static func makeItemView(with inititalState: InspectorElementSectionState) -> InspectorElementSectionView {
        InspectorElementKeyCommandSectionView(state: inititalState)
    }

    func addTitleAccessoryView(_ titleAccessoryView: UIView?) {
        formView.addTitleAccessoryView(titleAccessoryView)
    }

    func addFormViews(_ formViews: [UIView]) {
        formView.addFormViews(formViews)
    }
}
