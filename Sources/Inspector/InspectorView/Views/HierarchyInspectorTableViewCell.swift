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

class HierarchyInspectorTableViewCell: UITableViewCell, ElementInspectorAppearanceProviding {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        backgroundView = UIView()
        backgroundColor = nil

        textLabel?.textColor = colorStyle.textColor
        detailTextLabel?.textColor = colorStyle.secondaryTextColor

        selectedBackgroundView = UIView().then {
            let colorView = BaseView(
                .clipsToBounds(true),
                .backgroundColor(colorStyle.softTintColor),
                .layerOptions(
                    .cornerRadius(elementInspectorAppearance.verticalMargins / 2)
                )
            )

            $0.installView(
                colorView,
                .spacing(
                    horizontal: elementInspectorAppearance.verticalMargins,
                    vertical: .zero
                )
            )
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        layer.mask = nil
    }
}
