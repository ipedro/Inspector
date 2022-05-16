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

protocol OptionListControlDelegate: AnyObject {
    func optionListControlDidTap(_ optionListControl: OptionListControl)
    func optionListControlDidChangeSelectedIndex(_ optionListControl: OptionListControl)
}

final class OptionListControl: BaseFormControl {
    // MARK: - Properties

    weak var delegate: OptionListControlDelegate?

    override var isEnabled: Bool {
        didSet {
            icon.isHidden = !isEnabled
            valueLabel.textColor = textColor
            accessoryControl.isEnabled = isEnabled
        }
    }

    private lazy var icon = Icon(.chevronUpDown, color: textColor, size: CGSize(width: 14, height: 14))

    private var textColor: UIColor {
        isEnabled ? colorStyle.textColor : colorStyle.secondaryTextColor
    }

    private lazy var valueLabel = UILabel(
        .textStyle(.footnote),
        .textColor(textColor)
    ).then {
        $0.allowsDefaultTighteningForTruncation = true
        $0.lineBreakMode = .byTruncatingMiddle
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.contentView.addArrangedSubviews(valueLabel, icon)
        $0.contentView.alignment = .center
        $0.contentView.spacing = elementInspectorAppearance.verticalMargins
        $0.contentView.directionalLayoutMargins.update(top: elementInspectorAppearance.verticalMargins, bottom: elementInspectorAppearance.verticalMargins)

    }

    // MARK: - Init

    let options: [Swift.CustomStringConvertible]

    let emptyTitle: String

    var selectedIndex: Int? {
        didSet {
            updateViews()
        }
    }

    init(
        title: String?,
        options: [Swift.CustomStringConvertible],
        emptyTitle: String,
        selectedIndex: Int? = nil
    ) {
        self.options = options

        self.selectedIndex = selectedIndex

        self.emptyTitle = emptyTitle

        super.init(title: title)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        contentView.addArrangedSubview(accessoryControl)

        accessoryControl.widthAnchor.constraint(greaterThanOrEqualTo: contentContainerView.widthAnchor, multiplier: 1 / 2).isActive = true

        updateViews()

        if #available(iOS 14.0, *) {
            showsMenuAsPrimaryAction = true
            isContextMenuInteractionEnabled = true
        }
        else {
            accessoryControl.addTarget(self, action: #selector(tap), for: .touchUpInside)
        }
    }

    func updateSelectedIndex(_ selectedIndex: Int?) {
        self.selectedIndex = selectedIndex

        sendActions(for: .valueChanged)
    }

    private func updateViews() {
        guard let selectedIndex = selectedIndex else {
            valueLabel.text = emptyTitle
            return
        }

        valueLabel.text = options[selectedIndex].description
    }

    // MARK: - Actions

    @objc private func tap() {
        delegate?.optionListControlDidTap(self)
    }

    @available(iOS 14.0, *)
    override func menuAttachmentPoint(for configuration: UIContextMenuConfiguration) -> CGPoint {
        switch axis {
        case .horizontal:
            let point = CGPoint(x: accessoryControl.bounds.maxX, y: accessoryControl.bounds.minY)
            let localPoint = accessoryControl.convert(point, to: self)
            return localPoint

        default:
            return super.menuAttachmentPoint(for: configuration)
        }
    }

    @available(iOS 14.0, *)
    override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let localPoint = convert(location, to: accessoryControl)

        guard accessoryControl.point(inside: localPoint, with: nil) else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return self.makeOptionSelectionMenu()
        }
    }

    @available(iOS 14.0, *)
    private func makeOptionSelectionMenu() -> UIMenu {
        UIMenu(
            title: String(),
            image: nil,
            identifier: nil,
            options: .displayInline,
            children: options.enumerated().map { index, option in
                UIAction(
                    title: option.description,
                    identifier: nil,
                    discoverabilityTitle: option.description,
                    state: index == self.selectedIndex ? .on : .off
                ) { [weak self] _ in
                    guard let self = self else { return }

                    self.selectedIndex = index
                    self.delegate?.optionListControlDidChangeSelectedIndex(self)
                }
            }
        )
    }
}
