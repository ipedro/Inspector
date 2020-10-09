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
            elementNameLabel.font = {
                switch viewModel?.relativeDepth {
                case 0:
                    return .systemFont(ofSize: 16, weight: .bold)
                    
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
            
            // Collapse
            
            isCollapsed = viewModel?.isCollapsed == true
            chevronDownIcon.isSafelyHidden = viewModel?.isContainer != true
            
            // Description
            
            descriptionLabel.text = viewModel?.subtitle
            
            // Containers Insets
            
            let offset = 28 * CGFloat(viewModel?.relativeDepth ?? 0)
            
            separatorInset = .init(top: 0, left: offset, bottom: 0, right: 0)
            directionalLayoutMargins = .margins(leading: offset)
            stackView.directionalLayoutMargins = directionalLayoutMargins
        }
    }
    
    var isEvenRow = false {
        didSet {
            if #available(iOS 13.0, *) {
                switch isEvenRow {
                case true:
                    backgroundColor = .systemBackground

                case false:
                    backgroundColor = .secondarySystemBackground
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
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var descriptionLabel = UILabel(.caption2).then {
        $0.numberOfLines = 0
        $0.alpha = 0.5
    }
    
    private lazy var chevronDownIcon = Icon(.chevronDown, color: elementNameLabel.textColor).then {
        $0.tintColor = elementNameLabel.textColor
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
            .margins(top: 15, leading: 30, bottom: 20, trailing: 15)
        )
        
        contentView.addSubview(chevronDownIcon)
        
        chevronDownIcon.centerYAnchor.constraint(equalTo: elementNameLabel.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(equalTo: elementNameLabel.leadingAnchor, constant: -5).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
    }
}
