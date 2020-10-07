//
//  ViewHierarchyListTableViewCodeCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListTableViewCodeCell: UITableViewCell, InternalViewProtocol {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: ViewHierarchyListItemViewModelProtocol? {
        didSet {
            backgroundColor = viewModel?.backgroundColor
            
            textLabel?.text = viewModel?.title
            textLabel?.adjustsFontSizeToFitWidth = true
            textLabel?.font = {
                switch viewModel?.depth {
                case 0:
                    return .systemFont(ofSize: 24, weight: .bold)
                    
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
            
            detailTextLabel?.text = viewModel?.subtitle
            detailTextLabel?.numberOfLines = 0
            detailTextLabel?.alpha = 0.5
            
            if let viewModel = viewModel {
                directionalLayoutMargins = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: 30 * CGFloat(viewModel.depth),
                    bottom: 20,
                    trailing: 15
                )
            }
            else {
                directionalLayoutMargins = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: 0,
                    bottom: 20,
                    trailing: 15
                )
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
    }
}
