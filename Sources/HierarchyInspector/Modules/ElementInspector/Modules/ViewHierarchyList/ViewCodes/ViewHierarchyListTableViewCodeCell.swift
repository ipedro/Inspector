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
                    return .systemFont(ofSize: 15, weight: .semibold)
                    
                case 2:
                    return .systemFont(ofSize: 14, weight: .semibold)
                    
                case 3:
                    return .systemFont(ofSize: 13, weight: .semibold)
                    
                default:
                    return .systemFont(ofSize: 13, weight: .medium)
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
            stackView.directionalLayoutMargins = directionalLayoutMargins
        }
    }
    
    var isEvenRow = false {
        didSet {
            #warning("move to theme")
            if #available(iOS 13.0, *) {
                switch isEvenRow {
                case true:
                    backgroundColor = .secondarySystemBackground

                case false:
                    backgroundColor = .tertiarySystemBackground
                }
            } else {
                switch isEvenRow {
                case true:
                    backgroundColor = .white

                case false:
                    backgroundColor = UIColor(white: 0.05, alpha: 1)
                }
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
            withDuration: 0.25,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                
                self.isCollapsed.toggle()
                
            },
            completion: nil
        )
    }
    
    private lazy var elementNameLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.preferredMaxLayoutWidth = 200
    }
    
    private lazy var descriptionLabel = UILabel(.caption2, numberOfLines: 0).then {
        $0.preferredMaxLayoutWidth = 200
        $0.alpha = 0.5
    }
    
    private lazy var chevronDownIcon = Icon(
        .chevronDown,
        color: elementNameLabel.textColor.withAlphaComponent(0.7),
        size: CGSize(
            width: 12,
            height: 12
        )
    ).then {
        $0.alpha = 0.8
    }
    
    private lazy var stackView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            elementNameLabel,
            descriptionLabel
        ],
        spacing: 4
    )
    
    func setup() {
        contentView.clipsToBounds = true
        
        backgroundColor = nil
        
        contentView.installView(
            stackView,
            .margins(
                top: ElementInspector.appearance.verticalMargins,
                leading: 0,
                bottom: ElementInspector.appearance.verticalMargins,
                trailing: ElementInspector.appearance.verticalMargins
            )
        )
        
        contentView.addSubview(chevronDownIcon)
        
        chevronDownIcon.centerYAnchor.constraint(equalTo: elementNameLabel.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(equalTo: elementNameLabel.leadingAnchor, constant: -4).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
    }
}
