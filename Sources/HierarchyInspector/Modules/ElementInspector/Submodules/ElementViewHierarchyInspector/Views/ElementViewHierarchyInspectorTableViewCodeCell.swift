//
//  ElementViewHierarchyInspectorTableViewCodeCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ElementViewHierarchyInspectorTableViewCodeCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: ElementViewHierarchyPanelViewModelProtocol? {
        didSet {
            
            // Name
            
            elementNameLabel.text = viewModel?.title

            elementNameLabel.font = viewModel?.titleFont
            
            thumbnailImageView.image = viewModel?.thumbnailImage
            
            accessoryType = viewModel?.accessoryType ?? .none

            // Collapsed

            isCollapsed = viewModel?.isCollapsed == true
            
            chevronDownIcon.isSafelyHidden = viewModel?.isContainer != true || viewModel?.accessoryType == .disclosureIndicator

            // Description

            descriptionLabel.text = viewModel?.subtitle

            // Containers Insets

            let relativeDepth = CGFloat(viewModel?.relativeDepth ?? 0)
            let offset = (ElementInspector.appearance.verticalMargins * relativeDepth) + ElementInspector.appearance.horizontalMargins

            separatorInset = .insets(left: offset)
            directionalLayoutMargins = .margins(leading: offset)
            containerStackView.directionalLayoutMargins = directionalLayoutMargins
        }
    }
    
    var isEvenRow = false {
        didSet {
            switch isEvenRow {
            case true:
                backgroundColor = ElementInspector.appearance.panelBackgroundColor
                
            case false:
                backgroundColor = ElementInspector.appearance.panelHighlightBackgroundColor
            }
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
    
    private lazy var elementNameLabel = UILabel().then {
        $0.textColor = ElementInspector.appearance.textColor
        $0.layer.shouldRasterize = true
        $0.layer.rasterizationScale = UIScreen.main.scale
        
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.preferredMaxLayoutWidth = 200
    }
    
    private lazy var descriptionLabel = UILabel(
        .caption2,
        textColor: ElementInspector.appearance.secondaryTextColor,
        numberOfLines: 0
    ).then {
        $0.layer.shouldRasterize = true
        $0.layer.rasterizationScale = UIScreen.main.scale
        
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        $0.preferredMaxLayoutWidth = 200
    }
    
    private lazy var chevronDownIcon = Icon.chevronDownIcon()
    
    private lazy var thumbnailImageView = UIImageView().then {
        $0.contentMode = .center
        $0.tintColor = ElementInspector.appearance.textColor
        $0.backgroundColor = ElementInspector.appearance.quaternaryTextColor
        
        $0.clipsToBounds = true
        
        $0.layer.cornerRadius = ElementInspector.appearance.verticalMargins / 2
        
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private lazy var textStackView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            elementNameLabel,
            descriptionLabel
        ],
        spacing: ElementInspector.appearance.verticalMargins / 2
    )
    
    private(set) lazy var containerStackView = UIStackView(
        axis: .horizontal,
        arrangedSubviews: [
            thumbnailImageView,
            textStackView
        ],
        spacing: ElementInspector.appearance.verticalMargins
    ).then {
        $0.alignment = .center
    }
    
    private lazy var customSelectedBackgroundView = UIView().then {
        $0.backgroundColor = ElementInspector.appearance.tintColor.withAlphaComponent(0.1)
    }
    
    private func setup() {
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        isOpaque = true
        
        contentView.isUserInteractionEnabled = false
        
        contentView.clipsToBounds = true
        
        selectedBackgroundView = customSelectedBackgroundView
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        setupContainerStackView()
        
        setupChevronDownIcon()
    }
    
    private func setupContainerStackView() {
        contentView.installView(
            containerStackView,
            .margins(
                top: ElementInspector.appearance.verticalMargins,
                leading: .zero,
                bottom: ElementInspector.appearance.verticalMargins,
                trailing: ElementInspector.appearance.verticalMargins
            )
        )
    }
    
    private func setupChevronDownIcon() {
        contentView.addSubview(chevronDownIcon)
        
        chevronDownIcon.centerYAnchor.constraint(equalTo: elementNameLabel.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(
            equalTo: elementNameLabel.leadingAnchor,
            constant: -(ElementInspector.appearance.verticalMargins / 3)
        ).isActive = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        
        thumbnailImageView.image = nil
    }
    
}
