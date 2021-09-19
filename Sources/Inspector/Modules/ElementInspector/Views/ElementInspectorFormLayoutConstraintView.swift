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

final class ElementInspectorFormLayoutConstraintView: BaseView, InspectorElementFormSectionView {
    var title: String? {
        get { header.title }
        set { header.title = newValue }
    }

    var subtitle: String? {
        get { header.subtitle }
        set { header.subtitle = newValue }
    }

    var separatorStyle: InspectorElementFormSectionSeparatorStyle {
        get { .none }
        set {}
    }

    static func createSectionView() -> InspectorElementFormSectionView {
        ElementInspectorFormLayoutConstraintView()
    }

    private lazy var formView = ElementInspectorFormSectionContentView(header: header).then {
        $0.separatorStyle = .none
    }

    var delegate: InspectorElementFormSectionViewDelegate? {
        get { formView.delegate }
        set { formView.delegate = newValue }
    }

    var state: InspectorElementFormSectionState {
        get { formView.state }
        set { formView.state = newValue }
    }

    private(set) lazy var header = SectionHeader(
        titleFont: .init(.footnote, .traitBold),
        subtitleFont: .footnote,
        margins: .init(vertical: ElementInspector.appearance.verticalMargins / 2)
    )

    private lazy var cardView = BaseCardView().then {
        var insets = ElementInspector.appearance.directionalInsets
        insets.bottom = insets.leading
        insets.top = .zero

        $0.insets = insets
        $0.backgroundColor = colorStyle.highlightBackgroundColor
        $0.contentView.addArrangedSubview(formView)

    }

    override func setup() {
        super.setup()

        contentView.addArrangedSubview(cardView)
    }

    func addFormViews(_ formViews: [UIView]) {
        formView.addFormViews(formViews)
    }
}
