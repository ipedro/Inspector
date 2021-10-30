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
@_implementationOnly import UIKitOptions

protocol ElementChildrenPanelTableViewCodeCellDelegate: AnyObject {
    func elementChildrenPanelTableViewCodeCellDidToggleCollapse(_ cell: ElementChildrenPanelTableViewCodeCell)
}

protocol ElementChildrenPanelTableViewCellViewModelProtocol: ElementChildrenPanelItemViewModelProtocol {
    var summaryInfo: ViewHierarchyElementSummary { get }
    var showDisclosureIcon: Bool { get }
    var appearance: (transform: CGAffineTransform, alpha: CGFloat) { get }
    var animatedDisplay: Bool { get set }
    var isHidden: Bool { get }
}

final class ElementChildrenPanelTableViewCodeCell: UITableViewCell {
    weak var delegate: ElementChildrenPanelTableViewCodeCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var elementDescriptionView = ViewHierarchyElementDescriptionView().then {
        $0.directionalLayoutMargins = .zero
    }

    private lazy var disclosureIcon = Icon(.chevronDown, color: colorStyle.tertiaryTextColor).then {
        $0.transform = .init(rotationAngle: -(.pi / 2))
    }

    private lazy var disclosureIconContainer = BaseView().then {
        $0.installView(disclosureIcon, .spacing(leading: .zero, trailing: .zero))
    }

    private lazy var containerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.isLayoutMarginsRelativeArrangement = true
        $0.addArrangedSubviews(elementDescriptionView, disclosureIconContainer)
        $0.directionalLayoutMargins = defaultContainerMargins
    }

    private let defaultContainerMargins = ElementInspector.appearance.directionalInsets

    var viewModel: ElementChildrenPanelTableViewCellViewModelProtocol? {
        didSet {
            contentView.isUserInteractionEnabled = true
            elementDescriptionView.summaryInfo = viewModel?.summaryInfo
            disclosureIcon.isHidden = viewModel?.showDisclosureIcon != true
        }
    }

    var isFirst: Bool = false {
        didSet {
            elementDescriptionView.elementNameLabel.isSafelyHidden = isFirst

            if isFirst {
                containerStackView.directionalLayoutMargins = defaultContainerMargins.with(
                    top: .zero,
                    trailing: ElementInspector.appearance.horizontalMargins
                )
                elementDescriptionView.directionalLayoutMargins = .init(
                    bottom: ElementInspector.appearance.verticalMargins
                )
            }
            else {
                containerStackView.directionalLayoutMargins = defaultContainerMargins

                elementDescriptionView.directionalLayoutMargins = .init(
                    horizontal: .zero,
                    vertical: ElementInspector.appearance.verticalMargins
                )
            }
        }
    }

    var isEvenRow = false {
        didSet {
            switch isEvenRow {
            case false:
                backgroundColor = colorStyle.cellHighlightBackgroundColor

            case true:
                backgroundColor = .none
            }
        }
    }

    func toggleCollapse(animated: Bool) {
        elementDescriptionView.toggleCollapse(animated: animated)
    }

    private lazy var customSelectedBackgroundView = UIView(
        .backgroundColor(colorStyle.softTintColor)
    )

    private func setup() {
        setContentHuggingPriority(.defaultHigh, for: .vertical)

        isOpaque = true

        clipsToBounds = true

        selectedBackgroundView = customSelectedBackgroundView

        backgroundColor = colorStyle.backgroundColor

        contentView.directionalLayoutMargins = .zero

        elementDescriptionView.collapseButton.isEnabled = false

        contentView.installView(containerStackView, priority: .required)

        disclosureIcon.centerYAnchor.constraint(equalTo: elementDescriptionView.iconImageView.centerYAnchor).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        contentView.alpha = 1
        elementDescriptionView.elementNameLabel.isSafelyHidden = false
        transform = .identity
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard areTouchesInsideCollapseButton(touches, with: event) else {
            return super.touchesBegan(touches, with: event)
        }

        elementDescriptionView.collapseButton.animate(.in)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard areTouchesInsideCollapseButton(touches, with: event) else {
            return super.touchesCancelled(touches, with: event)
        }

        elementDescriptionView.collapseButton.animate(.out)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard areTouchesInsideCollapseButton(touches, with: event) else {
            return super.touchesEnded(touches, with: event)
        }

        elementDescriptionView.collapseButton.animate(.out)
        debounce(#selector(triggerCollapseButton), delay: 0.15, object: nil)
    }

    @objc private func triggerCollapseButton() {
        delegate?.elementChildrenPanelTableViewCodeCellDidToggleCollapse(self)
    }

    private func areTouchesInsideCollapseButton(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard
            event?.type == .touches,
            let touch = touches.first,
            elementDescriptionView.collapseButton.isUserInteractionEnabled,
            elementDescriptionView.collapseButton.isHidden == false,
            isPointNearCollapseButton(touch.location(in: self))
        else {
            return false
        }

        return true
    }

    private func isPointNearCollapseButton(_ point: CGPoint) -> Bool {
        let buttonFrame = elementDescriptionView.collapseButton.convert(elementDescriptionView.collapseButton.bounds, to: self)

        return bounds.contains(point) && point.x <= buttonFrame.maxX + elementDescriptionView.contentView.spacing * 1.5
    }
}
