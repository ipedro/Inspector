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

final class ElementInspectorLayoutConstraintCard: BaseCard, ElementInspectorFormSectionView {
    private lazy var formView = ElementInspectorFormSectionContentView.init(
        header: header
    ).then {
        $0.topSeparatorView.isHidden = true
    }

    var delegate: ElementInspectorFormSectionViewDelegate? {
        get { formView.delegate }
        set { formView.delegate = newValue }
    }

    var isCollapsed: Bool {
        get { formView.isCollapsed }
        set { formView.isCollapsed = newValue }
    }

    var inputContainerView: UIStackView { formView.inputContainerView }

    private(set) lazy var header = SectionHeader(
        titleFont: .init(.footnote, .traitBold),
        subtitleFont: .caption2
    )

    override func setup() {
        super.setup()

        var insets = ElementInspector.appearance.directionalInsets
        insets.top = .zero

        self.insets = insets
        contentMargins = .init(leading: ElementInspector.appearance.verticalMargins / 2)
        backgroundColor = ElementInspector.appearance.panelHighlightBackgroundColor

        contentView.addArrangedSubview(formView)
    }
}
