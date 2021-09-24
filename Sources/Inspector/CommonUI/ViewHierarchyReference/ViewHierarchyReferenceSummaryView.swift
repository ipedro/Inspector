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
    var thumbnailImage: UIImage? { get }

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

        thumbnailImageView.image = viewModel?.thumbnailImage

        // Collapsed

        isCollapsed = viewModel?.isCollapsed == true

        let hideCollapse = viewModel?.showCollapseButton != true
        collapseButton.isHidden = hideCollapse

        collapseButtonContainer.isHidden = hideCollapse && viewModel?.automaticallyAdjustIndentation == false

        // Description

        descriptionLabel.text = viewModel?.subtitle

        // Containers Insets

        let relativeDepth = viewModel?.relativeDepth ?? 0
        let indentation = CGFloat(relativeDepth) * ElementInspector.appearance.horizontalMargins

        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(leading: indentation)
    }

    private lazy var containerStackView = UIStackView().then {
        $0.isLayoutMarginsRelativeArrangement = true
        $0.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
        $0.addArrangedSubview(contentView)
    }

    override var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { containerStackView.directionalLayoutMargins }
        set { containerStackView.directionalLayoutMargins = newValue }
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
        $0.numberOfLines = .zero
        $0.preferredMaxLayoutWidth = 150
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
        $0.allowsDefaultTighteningForTruncation = true
    }

    private(set) lazy var descriptionLabel = UILabel().then {
        $0.preferredMaxLayoutWidth = 150
        $0.font = .preferredFont(forTextStyle: .caption2)
        $0.textColor = colorStyle.secondaryTextColor
        $0.numberOfLines = .zero
    }

    private lazy var collapseButtonContainer = UIView().then {
        $0.installView(collapseButton)
    }

    private(set) lazy var collapseButton = IconButton(.chevronDown)

    private(set) lazy var thumbnailContainerView = BaseView().then {
        $0.backgroundColor = colorStyle.accessoryControlBackgroundColor
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.installView(thumbnailImageView, .spacing(all: $0.layer.cornerRadius / 2))
    }

    private(set) lazy var thumbnailImageView = UIImageView().then {
        $0.clipsToBounds = false
        $0.contentMode = .scaleAspectFit
        $0.tintColor = colorStyle.textColor
        $0.widthAnchor.constraint(equalToConstant: 32).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
    }

    private(set) lazy var textStackView = UIStackView().then {
        $0.axis = .vertical
        $0.addArrangedSubviews(elementNameLabel, descriptionLabel)
        $0.spacing = ElementInspector.appearance.verticalMargins / 2
        $0.clipsToBounds = true
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

        contentView.axis = .horizontal
        contentView.spacing = ElementInspector.appearance.verticalMargins
        contentView.alignment = .center
        contentView.addArrangedSubviews(collapseButtonContainer, textStackView, thumbnailContainerView)

        installView(containerStackView)
    }
}
