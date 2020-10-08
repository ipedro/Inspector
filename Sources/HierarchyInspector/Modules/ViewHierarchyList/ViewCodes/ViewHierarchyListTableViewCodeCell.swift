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
            backgroundColor = viewModel?.backgroundColor
            
            elementNameLabel.text = viewModel?.title
            
            elementNameLabel.font = {
                switch viewModel?.depth {
                case 0:
                    return .systemFont(ofSize: 22, weight: .bold)
                    
                case 1:
                    return .systemFont(ofSize: 18, weight: .semibold)
                    
                case 2:
                    return .systemFont(ofSize: 16, weight: .semibold)
                    
                case 3:
                    return .systemFont(ofSize: 14, weight: .medium)
                    
                default:
                    return .systemFont(ofSize: 14, weight: .regular)
                }
            }()
            
            isCollapsedLabel.font = elementNameLabel.font
            
            descriptionLabel.text = viewModel?.subtitle
            
            let offset = 30 * (CGFloat(viewModel?.depth ?? 0) + 1)
            
            separatorInset = .init(top: 0, left: offset, bottom: 0, right: 0)
            
            directionalLayoutMargins = .margins(leading: offset)
            
            stackView.directionalLayoutMargins = directionalLayoutMargins
            
            isCollapsed = viewModel?.isCollapsed == true
            
            isCollapsedLabel.isSafelyHidden = viewModel?.isContainer != true
        }
    }
    
    var isCollapsed = false {
        didSet {
            isCollapsedLabel.transform = isCollapsed ? .identity : .init(rotationAngle: .pi / 2)
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
            options: .beginFromCurrentState,
            animations: {
                
                self.isCollapsed.toggle()
                
            },
            completion: nil
        )
    }
    
    private lazy var elementNameLabel = UILabel().then {
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var descriptionLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption2)
        $0.numberOfLines = 0
        $0.alpha = 0.5
    }
    
    private lazy var isCollapsedLabel = UILabel().then {
        $0.text = "›"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = elementNameLabel.textColor
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
        selectionStyle = .none
        
        contentView.installView(
            stackView,
            .margins(top: 20, leading: 10, bottom: 20, trailing: 20)
        )
        
        contentView.addSubview(isCollapsedLabel)
        
        isCollapsedLabel.centerYAnchor.constraint(equalTo: elementNameLabel.centerYAnchor).isActive = true

        isCollapsedLabel.trailingAnchor.constraint(equalTo: elementNameLabel.leadingAnchor, constant: -8).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
    }
}
