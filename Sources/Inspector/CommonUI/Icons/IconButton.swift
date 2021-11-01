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

final class IconButton: BaseControl {
    typealias Action = () -> Void

    enum Style {
        case rounded
        case plain

        fileprivate func cornerRadius(for view: UIView) -> CGFloat {
            switch self {
            case .rounded:
                return view.frame.height / 2
            case .plain:
                return .zero
            }
        }

        fileprivate var layoutMargins: NSDirectionalEdgeInsets { .init(insets: ElementInspector.appearance.verticalMargins / 3) }
    }

    let style: Style

    let icon: Icon

    var actionHandler: Action?

    init(
        _ glyph: Icon.Glyph,
        style: Style = .rounded,
        size: CGSize = .init(16),
        tintColor: UIColor = Inspector.configuration.colorStyle.textColor,
        actionHandler: Action? = nil
    ) {
        icon = Icon(glyph, color: tintColor, size: size)
        self.style = style
        self.actionHandler = actionHandler
        super.init(frame: .zero)
        self.tintColor = tintColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        applyStyle()
    }

    private func applyStyle() {
        switch style {
        case .plain:
            icon.tintColor = tintColor
            backgroundColor = .clear
        case .rounded:
            icon.tintColor = tintColor
            backgroundColor = colorStyle.accessoryControlBackgroundColor
        }

        clipsToBounds = true
    }

    override func setup() {
        super.setup()

        enableRasterization()

        contentView.axis = .vertical
        contentView.addArrangedSubview(icon)
        contentView.directionalLayoutMargins = style.layoutMargins

        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)

        applyStyle()
    }

    @objc private func touchUpInside() {
        actionHandler?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = style.cornerRadius(for: self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(.in)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(.out)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(.out)
    }
}
