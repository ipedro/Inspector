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

class BaseCardView: BaseView {
    private(set) lazy var containerView = BaseView().then {
        $0.installView(roundedView, priority: .required)
    }

    private(set) lazy var roundedView = BaseView().then {
        $0.layer.borderColor = borderColor?.cgColor
        $0.layer.borderWidth = 0
        $0.installView(contentView, priority: .required)
        $0.layer.cornerRadius = cornerRadius
    }

    private lazy var stackView = UIStackView.vertical(
        .arrangedSubviews(containerView),
        .isLayoutMarginsRelativeArrangement(true),
        .directionalLayoutMargins(margins)
    )

    var margins: NSDirectionalEdgeInsets = .zero {
        didSet {
            stackView.directionalLayoutMargins = margins
        }
    }

    var cornerRadius: CGFloat = .zero {
        didSet {
            roundedView.layer.cornerRadius = cornerRadius
        }
    }

    var contentMargins: NSDirectionalEdgeInsets = .zero {
        didSet {
            contentView.directionalLayoutMargins = contentMargins
        }
    }

    override var backgroundColor: UIColor? {
        get { roundedView.backgroundColor }
        set { roundedView.backgroundColor = newValue }
    }

    var borderColor: UIColor? {
        didSet {
            updateViews()
        }
    }

    var borderWidth: CGFloat {
        get { roundedView.layer.borderWidth }
        set { roundedView.layer.borderWidth = newValue }
    }

    override func setup() {
        super.setup()

        cornerRadius = elementInspectorAppearance.horizontalMargins

        installView(stackView, priority: .required)

        contentView.directionalLayoutMargins = contentMargins

        updateViews()
    }

    private func updateViews() {
        roundedView.layer.borderColor = borderColor?.cgColor
        roundedView.layer.borderWidth = borderWidth
    }
}
