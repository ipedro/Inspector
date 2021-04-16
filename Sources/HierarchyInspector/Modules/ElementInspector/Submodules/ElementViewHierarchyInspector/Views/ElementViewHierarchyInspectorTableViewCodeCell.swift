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
    
    private lazy var referenceDetailView = ViewHierarchyReferenceDetailView()
    
    var viewModel: ElementViewHierarchyPanelViewModelProtocol? {
        didSet {
            
            referenceDetailView.viewModel = viewModel
            
            accessoryType = viewModel?.accessoryType ?? .none
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
    
    func toggleCollapse(animated: Bool) {
        guard animated else {
            referenceDetailView.isCollapsed.toggle()
            return
        }
        
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak self] in
                
                self?.referenceDetailView.isCollapsed.toggle()
                
            },
            completion: nil
        )
    }
    
    private lazy var customSelectedBackgroundView = UIView(
        .backgroundColor(ElementInspector.appearance.tintColor.withAlphaComponent(0.1))
    )
    
    private func setup() {
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        isOpaque = true
        
        clipsToBounds = true
        
        selectedBackgroundView = customSelectedBackgroundView
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        contentView.isUserInteractionEnabled = false
        
        contentView.installView(referenceDetailView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
    }
    
}
