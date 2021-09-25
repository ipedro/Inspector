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

protocol ViewHierarchyReferenceSummaryViewModelProtocol {
    var iconImage: UIImage? { get }

    var title: String { get }

    var titleFont: UIFont { get }

    var subtitle: String { get }

    var isContainer: Bool { get }

    var isCollapsed: Bool { get set }

    var showCollapseButton: Bool { get }

    var isHidden: Bool { get }

    var relativeDepth: Int { get }

    var automaticallyAdjustIndentation: Bool { get }
}

final class ViewHierarchyReferenceSummaryView: BaseView {
    var viewModel: ViewHierarchyReferenceSummaryViewModelProtocol? {
        didSet {
            reloadData()
        }
    }

    var isCollapsed = false {
        didSet {
            collapseButtonContainer.transform = .init(rotationAngle: isCollapsed ? -(.pi / 2) : .zero)
        }
    }

    func reloadData() {
        // Name

        elementNameLabel.text = viewModel?.title

        elementNameLabel.font = viewModel?.titleFont

        iconImageView.image = viewModel?.iconImage

        // Collapsed

        isCollapsed = viewModel?.isCollapsed == true

        let hideCollapse = viewModel?.showCollapseButton != true
        collapseButton.isHidden = hideCollapse

        collapseButtonContainer.isHidden = hideCollapse && viewModel?.automaticallyAdjustIndentation == false

        // Description

        elementDescriptionLabel.text = viewModel?.subtitle
        elementDescriptionLabel.numberOfLines = viewModel?.relativeDepth == .zero ? .zero : 3

        // Containers Insets

        let relativeDepth = viewModel?.relativeDepth ?? 0
        let indentation = CGFloat(relativeDepth) * ElementInspector.appearance.horizontalMargins

        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(leading: indentation)
    }

    private lazy var contentViewContainer = UIStackView().then {
        $0.isLayoutMarginsRelativeArrangement = true
        $0.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
        $0.addArrangedSubview(contentView)
    }

    override var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { contentViewContainer.directionalLayoutMargins }
        set { contentViewContainer.directionalLayoutMargins = newValue }
    }

    func toggleCollapse(animated: Bool) {
        guard animated else {
            isCollapsed.toggle()
            return
        }

        animate { [weak self] in
            self?.isCollapsed.toggle()
        }
    }

    private(set) lazy var elementNameLabel = UILabel().then {
        $0.textColor = colorStyle.textColor
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.numberOfLines = 1
        $0.preferredMaxLayoutWidth = 150
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
        $0.allowsDefaultTighteningForTruncation = true
    }

    private(set) lazy var elementDescriptionLabel = UILabel().then {
        $0.clipsToBounds = true
        $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.font = .preferredFont(forTextStyle: .caption2)
        $0.textColor = colorStyle.secondaryTextColor
    }

    private lazy var collapseButtonContainer = UIView().then {
        $0.installView(collapseButton)
    }

    private(set) lazy var collapseButton = IconButton(.chevronDown)

    private(set) lazy var iconContainerView = BaseView().then {
        $0.backgroundColor = colorStyle.accessoryControlBackgroundColor
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.installView(iconImageView, .spacing(all: $0.layer.cornerRadius / 2), priority: .required)
    }

    private(set) lazy var iconImageView = UIImageView().then {
        $0.clipsToBounds = false
        $0.contentMode = .scaleAspectFit
        $0.widthAnchor.constraint(equalToConstant: 32).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
    }

    private(set) lazy var elementIconAndDescriptionLabel = BaseView().then {
        $0.installView(
            iconContainerView,
                .spacing(
                    top: ElementInspector.appearance.verticalMargins / 2,
                    leading: .zero
                ),
            priority: .required
        )

        $0.installView(
            elementDescriptionLabel,
                .spacing(
                    top: .zero,
                    bottom: .zero,
                    trailing: .zero
                ),
            priority: .required
        )

        elementDescriptionLabel.bottomAnchor.constraint(
            greaterThanOrEqualTo: $0.bottomAnchor
        ).isActive = true

        elementDescriptionLabel.leadingAnchor.constraint(
            equalTo: iconContainerView.trailingAnchor,
            constant: ElementInspector.appearance.verticalMargins
        ).isActive = true

        $0.heightAnchor.constraint(
            greaterThanOrEqualTo: iconContainerView.heightAnchor,
            constant: ElementInspector.appearance.verticalMargins
        ).isActive = true

    }

    private(set) lazy var elementDetailsContainer = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = ElementInspector.appearance.verticalMargins / 2
        $0.addArrangedSubviews(elementNameLabel, elementIconAndDescriptionLabel)
    }

    private lazy var heighConstraint = heightAnchor.constraint(equalToConstant: .zero)

    override func layoutSubviews() {
        super.layoutSubviews()

        guard frame.isEmpty == false else { return }

        let size = systemLayoutSizeFitting(
            CGSize(width: frame.width, height: .zero),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        guard size.height != heighConstraint.constant else { return }

        self.heighConstraint.constant = size.height
    }

    override func setup() {
        super.setup()

        tintColor = colorStyle.textColor

        contentView.axis = .horizontal
        contentView.spacing = ElementInspector.appearance.horizontalMargins
        contentView.alignment = .center
        contentView.addArrangedSubviews(collapseButtonContainer, elementDetailsContainer)

        installView(contentViewContainer)
    }
}
