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

final class SeparatorView: BaseView {
    enum Style: ColorStylable {
        case soft
        case medium
        case hard
        case color(UIColor)

        fileprivate var color: UIColor {
            switch self {
            case .soft:
                return colorStyle.textColor.withAlphaComponent(0.09)
            case .medium:
                return colorStyle.textColor.withAlphaComponent(0.18)
            case .hard:
                return colorStyle.textColor.withAlphaComponent(0.27)
            case let .color(color):
                return color
            }
        }
    }

    var thickness: CGFloat {
        didSet {
            thicknessConstraint.constant = thicknesInPixels
        }
    }

    private var thicknesInPixels: CGFloat { thickness / UIScreen.main.scale }

    var style: Style {
        didSet {
            backgroundColor = style.color
        }
    }

    private lazy var thicknessConstraint = heightAnchor.constraint(equalToConstant: thicknesInPixels)

    convenience init(color: UIColor, thickness: CGFloat = 1, frame: CGRect = .zero) {
        self.init(style: .color(color), thickness: thickness, frame: frame)
    }

    init(style: Style, thickness: CGFloat = 1, frame: CGRect = .zero) {
        self.thickness = thickness
        self.style = style

        super.init(frame: frame)

        backgroundColor = style.color
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        thicknessConstraint.isActive = true
    }
}
