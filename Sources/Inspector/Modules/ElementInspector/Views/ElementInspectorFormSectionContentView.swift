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

final class ElementInspectorFormSectionContentView: BaseControl, ElementInspectorFormSectionView {
    // MARK: - Properties

    weak var delegate: ElementInspectorFormSectionViewDelegate?

    enum SeparatorStyle {
        case top
    }

    var separatorStyle: SeparatorStyle? {
        get { topSeparatorView.isHidden ? .none : .top }
        set {
            switch newValue {
            case .none:
                topSeparatorView.isHidden = true
            case .top:
                topSeparatorView.isHidden = false
            }
        }
    }

    var sectionState: UIControl.State {
        get { state }
        set {
            switch newValue {
            case .disabled:
                alpha = 0.5
                isSelected = false
                isEnabled = false
                hideContent(true)

            case .normal:
                alpha = 1
                isEnabled = true
                isSelected = false
                hideContent(true)

            case .selected:
                alpha = 1
                isEnabled = true
                isSelected = true
                hideContent(false)

            default:
                alpha = 1
                isSelected = false
                isEnabled = true
                hideContent(false)
            }
        }
    }

    // MARK: - Views

    private lazy var contentContainerView = UIStackView.vertical().then {
        $0.isLayoutMarginsRelativeArrangement = true
    }

    private lazy var topSeparatorView = SeparatorView(thickness: 1)

    var header: SectionHeader

    private lazy var headerControl = UIControl(.translatesAutoresizingMaskIntoConstraints(false)).then {
        $0.addTarget(self, action: #selector(tapHeader), for: .touchUpInside)
        $0.installView(header)
    }

    private lazy var chevronDownIcon = Icon.chevronDownIcon()

    convenience init() {
        self.init(header: SectionHeader.attributesInspectorHeader(), frame: .zero)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let headerAccessoryView = header.accessoryView,
           headerAccessoryView.point(inside: convert(point, to: headerAccessoryView), with: event) {
            return headerAccessoryView
        }

        if headerControl.point(inside: convert(point, to: headerControl), with: event) {
            return headerControl
        }

        return super.hitTest(point, with: event)
    }

    init(
        header: SectionHeader,
        frame: CGRect = .zero
    ) {
        self.header = header
        super.init(frame: frame)
    }

    func addFormViews(_ views: [UIView]) {
        contentContainerView.addArrangedSubviews(views)
    }

    override func setup() {
        super.setup()

        contentView.axis = .vertical
        contentView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
        contentView.addArrangedSubviews(headerControl, contentContainerView)
        contentView.setCustomSpacing(ElementInspector.appearance.verticalMargins, after: header)

        installSeparator()

        installIcon()
    }

    private func installIcon() {
        contentView.addSubview(chevronDownIcon)

        chevronDownIcon.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(
            equalTo: header.leadingAnchor,
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
        isSelected.toggle()
    }

    private func hideContent(_ hide: Bool) {
        contentContainerView.clipsToBounds = hide
        contentContainerView.isSafelyHidden = hide
        contentContainerView.alpha = hide ? 0 : 1
        chevronDownIcon.transform = hide ? CGAffineTransform(rotationAngle: -(.pi / 2)) : .identity
    }

    override func stateDidChange(from oldState: UIControl.State, to newState: UIControl.State) {
        delegate?.elementInspectorFormSectionView(self, changedFrom: oldState, to: newState)
    }
}
