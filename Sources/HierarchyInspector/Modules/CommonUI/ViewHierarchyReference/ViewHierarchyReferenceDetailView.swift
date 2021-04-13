//
//  ViewHierarchyReferenceDetailView.swift
//  HierarchyInspector
//
//  Created by Pedro on 13.04.21.
//

import UIKit

protocol ViewHierarchyReferenceDetailViewModelProtocol {
    var thumbnailImage: UIImage? { get }
    
    var title: String { get }
    
    var titleFont: UIFont { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isChevronHidden: Bool { get }
    
    var isHidden: Bool { get }
    
    var relativeDepth: Int { get }
}

final class ViewHierarchyReferenceDetailView: BaseView {
    
    var viewModel: ViewHierarchyReferenceDetailViewModelProtocol? {
        didSet {
            
            // Name
            
            elementNameLabel.text = viewModel?.title

            elementNameLabel.font = viewModel?.titleFont
            
            thumbnailImageView.image = viewModel?.thumbnailImage
            
            // Collapsed

            isCollapsed = viewModel?.isCollapsed == true
            
            chevronDownIcon.isSafelyHidden = viewModel?.isChevronHidden ?? true

            // Description

            descriptionLabel.text = viewModel?.subtitle

            // Containers Insets

            let relativeDepth = CGFloat(viewModel?.relativeDepth ?? 0)
            let offset = (ElementInspector.appearance.verticalMargins * relativeDepth)
            
            var directionalLayoutMargins = contentView.directionalLayoutMargins
            directionalLayoutMargins.leading = offset
            
            contentView.directionalLayoutMargins = directionalLayoutMargins
        }
    }
    
    var isCollapsed = false {
        didSet {
            chevronDownIcon.transform = isCollapsed ? .init(rotationAngle: -(.pi / 2)) : .identity
        }
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
        $0.textColor = ElementInspector.appearance.textColor
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.allowsDefaultTighteningForTruncation = true
        $0.preferredMaxLayoutWidth = 200
    }
    
    private(set) lazy var descriptionLabel = UILabel(
        .caption2,
        textColor: ElementInspector.appearance.secondaryTextColor,
        numberOfLines: 0
    ).then {
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        $0.preferredMaxLayoutWidth = 200
    }
    
    private(set) lazy var chevronDownIcon = Icon.chevronDownIcon()
    
    private(set) lazy var thumbnailImageView = UIImageView().then {
        $0.contentMode = .center
        $0.tintColor = ElementInspector.appearance.textColor
        $0.backgroundColor = ElementInspector.appearance.quaternaryTextColor
        
        $0.clipsToBounds = true
        
        $0.layer.cornerRadius = ElementInspector.appearance.verticalMargins / 2
        
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
    }
    
    private(set) lazy var textStackView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            elementNameLabel,
            descriptionLabel
        ],
        spacing: ElementInspector.appearance.verticalMargins / 2
    )
    
    override func setup() {
        super.setup()
        
        contentView.axis = .horizontal
        contentView.spacing = ElementInspector.appearance.verticalMargins
        contentView.alignment = .center
        contentView.addArrangedSubview(thumbnailImageView)
        contentView.addArrangedSubview(textStackView)
        
        installView(
            contentView,
            .insets(ElementInspector.appearance.directionalInsets),
            priority: .required
        )
    
        setupChevronDownIcon()
    }
    
    private func setupChevronDownIcon() {
        contentView.addSubview(chevronDownIcon)
        
        chevronDownIcon.centerYAnchor.constraint(equalTo: elementNameLabel.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(
            equalTo: elementNameLabel.leadingAnchor,
            constant: -(ElementInspector.appearance.verticalMargins / 3)
        ).isActive = true
        
    }
    
}
