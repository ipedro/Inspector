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

        var directionalLayoutMargins = contentView.directionalLayoutMargins
        directionalLayoutMargins.leading = indentation

        contentView.directionalLayoutMargins = directionalLayoutMargins
    }
    
    func toggleCollapse(animated: Bool) {
        guard animated else {
            isCollapsed.toggle()
            return
        }
        
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak self] in
                self?.isCollapsed.toggle()
            },
            completion: nil
        )
    }
    
    private(set) lazy var elementNameLabel = UILabel().then {
        $0.textColor = colorStyle.textColor
        $0.numberOfLines = .zero
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
        $0.allowsDefaultTighteningForTruncation = true
    }
    
    private(set) lazy var descriptionLabel = UILabel().then {
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
        $0.installView(thumbnailImageView, .margins($0.layer.cornerRadius / 2))
    }

    private(set) lazy var thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = colorStyle.textColor
        $0.widthAnchor.constraint(equalToConstant: 32).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
    }
    
    private(set) lazy var textStackView = UIStackView.vertical(
        .arrangedSubviews(
            elementNameLabel,
            descriptionLabel
        ),
        .spacing(ElementInspector.appearance.verticalMargins / 2)
    )
    
    override func setup() {
        super.setup()
        
        contentView.axis = .horizontal
        contentView.spacing = ElementInspector.appearance.verticalMargins
        contentView.alignment = .center
        contentView.addArrangedSubviews(collapseButtonContainer, thumbnailContainerView, textStackView)
        
        installView(
            contentView,
            .insets(ElementInspector.appearance.directionalInsets),
            priority: .required
        )
    }
}
