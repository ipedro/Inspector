//
//  HierarchyInspectorLayerActionCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

protocol HierarchyInspectorLayerAcionCellViewModelProtocol {
    var title: String { get }
    var icon: UIImage? { get }
    var isEnabled: Bool { get }
}

final class HierarchyInspectorLayerActionCell: HierarchyInspectorTableViewCell {
    
    var viewModel: HierarchyInspectorLayerAcionCellViewModelProtocol? {
        didSet {
            textLabel?.text = viewModel?.title
            
            imageView?.image = viewModel?.icon
            
            contentView.alpha = viewModel?.isEnabled == true ? 1 : ElementInspector.appearance.disabledAlpha
            
            selectionStyle = viewModel?.isEnabled == true ? .default : .none
        }
    }
    
    override func setup() {
        super.setup()
        
        tintColor = ElementInspector.appearance.textColor
        
        textLabel?.textColor = ElementInspector.appearance.textColor
        textLabel?.font = .preferredFont(forTextStyle: .callout)
    }
}
