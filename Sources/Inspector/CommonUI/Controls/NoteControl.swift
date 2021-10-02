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

public enum InspectorElemenPropertyNoteIcon: ColorStylable {
    case info, warning

    var image: UIImage? {
        switch self {
        case .info:
            return .infoOutlineSymbol

        case .warning:
            return .warningSymbol
        }
    }

    var color: UIColor {
        switch self {
        case .info:
            return colorStyle.tertiaryTextColor
        case .warning:
            return UIColor(hex: 0xDA7A3A)
        }
    }
}

final class NoteControl: BaseControl {
    let title: String?

    let text: String?

    let icon: InspectorElemenPropertyNoteIcon?

    init(icon: InspectorElemenPropertyNoteIcon?, title: String?, text: String?, frame: CGRect = .zero) {
        self.title = title
        self.text = text
        self.icon = icon
        super.init(frame: frame)
    }

    private lazy var imageView = UIImageView(image: icon?.image).then {
        $0.isHidden = icon == nil
        $0.tintColor = icon?.color
        $0.widthAnchor.constraint(equalToConstant: CGSize.regularIconSize.width).isActive = true
        $0.heightAnchor.constraint(equalToConstant: CGSize.regularIconSize.height).isActive = true
    }

    private lazy var header = SectionHeader(
        title: title,
        titleFont: .footnote,
        subtitle: text,
        subtitleFont: .caption2,
        margins: .init(
            leading: ElementInspector.appearance.verticalMargins,
            trailing: ElementInspector.appearance.horizontalMargins
        )
    ).then {
        $0.titleLabel.numberOfLines = 0
        $0.subtitleLabel.numberOfLines = 0
    }

    override func setup() {
        super.setup()

        contentView.axis = .horizontal

        contentView.alignment = .top

        contentView.spacing = .zero

        contentView.directionalLayoutMargins.update(bottom: ElementInspector.appearance.horizontalMargins)

        contentView.addArrangedSubviews(imageView, header)

        header.heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor).isActive = true
    }
}
