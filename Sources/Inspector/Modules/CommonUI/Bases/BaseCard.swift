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

class BaseCard: BaseView {
    private(set) lazy var backgroundView = UIView().then {
        $0.installView(contentView)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = cornerRadius
    }

    private lazy var stackView = UIStackView.vertical(
        .arrangedSubviews(backgroundView),
        .isLayoutMarginsRelativeArrangement(true),
        .directionalLayoutMargins(insets)
    )

    var insets: NSDirectionalEdgeInsets = .zero {
        didSet {
            stackView.directionalLayoutMargins = insets
        }
    }

    var cornerRadius: CGFloat = ElementInspector.appearance.verticalMargins {
        didSet {
            backgroundView.layer.cornerRadius = cornerRadius
        }
    }

    var contentMargins: NSDirectionalEdgeInsets = .zero {
        didSet {
            contentView.directionalLayoutMargins = contentMargins
        }
    }

    override var backgroundColor: UIColor? {
        get { backgroundView.backgroundColor }
        set { backgroundView.backgroundColor = newValue }
    }

    override func setup() {
        super.setup()

        installView(stackView)

        contentView.directionalLayoutMargins = contentMargins
    }
}
