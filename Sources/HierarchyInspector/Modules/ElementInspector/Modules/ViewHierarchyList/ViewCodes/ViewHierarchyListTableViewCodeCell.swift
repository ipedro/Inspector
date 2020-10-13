//
//  ViewHierarchyListTableViewCodeCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListTableViewCodeCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: ViewHierarchyListItemViewModelProtocol? {
        didSet {
            // Name
            
            elementNameLabel.text = viewModel?.title
            
            #warning("move style to ElementInspector.Appearance")
            elementNameLabel.font = {
                switch viewModel?.relativeDepth {
                case 0:
                    return UIFont.preferredFont(forTextStyle: .title3).bold()
                    
                case 1:
                    return UIFont.preferredFont(forTextStyle: .body).bold()
                    
                case 2:
                    return UIFont.preferredFont(forTextStyle: .caption1).bold()
                    
                case 3:
                    return UIFont.preferredFont(forTextStyle: .footnote).bold()
                    
                default:
                    return UIFont.preferredFont(forTextStyle: .footnote)
                }
            }()
            
            elementNameLabel.sizeToFit()
            
            if let relativeDepth = viewModel?.relativeDepth, relativeDepth > 0 {
                accessoryType = .detailButton
            }
            else {
                accessoryType = .none
            }
            
            // Collapse
            
            isCollapsed = viewModel?.isCollapsed == true
            chevronDownIcon.isSafelyHidden = viewModel?.isContainer != true
            
            // Description
            
            descriptionLabel.text = viewModel?.subtitle
            descriptionLabel.sizeToFit()
            
            // Containers Insets
            
            let offset = ElementInspector.appearance.horizontalMargins * (CGFloat(viewModel?.relativeDepth ?? 0) + 1)
            
            separatorInset = .init(top: 0, left: offset, bottom: 0, right: 0)
            directionalLayoutMargins = .margins(leading: offset)
            containerStackView.directionalLayoutMargins = directionalLayoutMargins
        }
    }
    
    #warning("move to theme")
    var isEvenRow = false {
        didSet {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                switch isEvenRow {
                case true:
                    backgroundColor = .secondarySystemBackground

                case false:
                    backgroundColor = .tertiarySystemBackground
                }
            }
            #else
            switch isEvenRow {
            case true:
                backgroundColor = .white

            case false:
                backgroundColor = UIColor(white: 0.05, alpha: 1)
            }
            #endif
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
            withDuration: 0.25,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak self] in
                
                self?.isCollapsed.toggle()
                
            },
            completion: nil
        )
    }
    
    private lazy var elementNameLabel = UILabel().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.preferredMaxLayoutWidth = 200
    }
    
    private lazy var descriptionLabel = UILabel(.caption2, numberOfLines: 0).then {
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        $0.preferredMaxLayoutWidth = 200
        $0.alpha = 0.5
    }
    
    private lazy var chevronDownIcon = Icon.chevronDownIcon()
    
    var thumbnailView: ViewHierarchyReferenceThumbnailView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let thumbnailView = thumbnailView {
                
                thumbnailView.layer.cornerRadius = ElementInspector.appearance.verticalMargins
                thumbnailView.contentView.directionalLayoutMargins = .margins(ElementInspector.appearance.verticalMargins / 2)
                thumbnailContainerView.isSafelyHidden = false
                thumbnailView.showEmptyStatusMessage = false
                
                thumbnailContainerView.installView(thumbnailView)
                
                thumbnailView.heightAnchor.constraint(equalTo: thumbnailContainerView.heightAnchor).isActive = true
                
                let widthConstraint = thumbnailView.widthAnchor.constraint(
                    equalTo: thumbnailView.heightAnchor,
                    multiplier: 4 / 3
                ).then {
                    $0.priority = .defaultHigh
                }
                
                widthConstraint.isActive = true
                
                thumbnailView.updateViews(afterScreenUpdates: true)
            }
            else {
                thumbnailContainerView.isSafelyHidden = true
            }
        }
    }
    
    private lazy var thumbnailContainerView = UIView().then {
        $0.heightAnchor.constraint(equalToConstant: ElementInspector.appearance.horizontalMargins * 2).isActive = true
        $0.isSafelyHidden = true
    }
    
    private lazy var containerStackView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            elementNameLabel,
            textStackView
        ],
        spacing: ElementInspector.appearance.verticalMargins / 2
    )
    
    private lazy var textStackView = UIStackView(
        axis: .horizontal,
        arrangedSubviews: [
            thumbnailContainerView,
            descriptionLabel
        ],
        spacing: ElementInspector.appearance.verticalMargins / 2
    ).then {
        $0.heightAnchor.constraint(greaterThanOrEqualToConstant: ElementInspector.appearance.horizontalMargins * 2).isActive = true
        $0.alignment = .firstBaseline
    }
    
    func setup() {
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        contentView.clipsToBounds = true
        
        backgroundColor = nil
        
        contentView.installView(
            containerStackView,
            .margins(
                top: ElementInspector.appearance.verticalMargins,
                leading: 0,
                bottom: ElementInspector.appearance.verticalMargins,
                trailing: ElementInspector.appearance.verticalMargins
            )
        )
        
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
        
        thumbnailView = nil
    }
}
