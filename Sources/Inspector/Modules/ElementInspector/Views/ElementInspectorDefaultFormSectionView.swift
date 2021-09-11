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

final class ElementInspectorDefaultFormSectionView: BaseView, ElementInspectorFormSectionView {
    weak var delegate: ElementInspectorFormSectionViewDelegate?

    private(set) lazy var inputContainerView = UIStackView.vertical()

    private lazy var topSeparatorView = SeparatorView(thickness: 1)

    private(set) lazy var sectionHeader = SectionHeader.attributesInspectorHeader()

    var isCollapsed: Bool = false {
        didSet {
            hideContent(isCollapsed)
        }
    }

    private lazy var toggleControl = UIControl(.translatesAutoresizingMaskIntoConstraints(false)).then {
        $0.addTarget(self, action: #selector(tapHeader), for: .touchUpInside)
    }

    private lazy var chevronDownIcon = Icon.chevronDownIcon()

    override func setup() {
        super.setup()

        hideContent(isCollapsed)

        backgroundColor = ElementInspector.appearance.panelBackgroundColor

        contentView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets

        contentView.addArrangedSubview(sectionHeader)

        contentView.addArrangedSubview(inputContainerView)

        contentView.setCustomSpacing(
            ElementInspector.appearance.verticalMargins,
            after: sectionHeader
        )

        installSeparator()

        installIcon()

        installHeaderControl()
    }

    private func installHeaderControl() {
        contentView.addSubview(toggleControl)

        toggleControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toggleControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        toggleControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toggleControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
    }

    private func installIcon() {
        contentView.addSubview(chevronDownIcon)

        chevronDownIcon.centerYAnchor.constraint(equalTo: sectionHeader.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(
            equalTo: sectionHeader.leadingAnchor,
            constant: -(ElementInspector.appearance.verticalMargins / 3)
        ).isActive = true
    }

    private func installSeparator() {
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topSeparatorView)

        topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }

    @objc private func tapHeader() {
        delegate?.elementInspectorFormSectionView(self, didToggle: isCollapsed)
    }

    private func hideContent(_ hide: Bool) {
        inputContainerView.clipsToBounds = hide
        inputContainerView.isSafelyHidden = hide
        inputContainerView.alpha = hide ? 0 : 1
        chevronDownIcon.transform = hide ? CGAffineTransform(rotationAngle: -(.pi / 2)) : .identity
    }
}
