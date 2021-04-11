//
//  HierarchyInspectorSnapshotCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

protocol HierarchyInspectorSnapshotCellViewModelProtocol {
    var title: String { get }
    var isEnabled: Bool { get }
    var subtitle: String { get }
    var image: UIImage? { get }
    var depth: Int { get }
    var reference: ViewHierarchyReference { get }
}

final class HierarchyInspectorSnapshotCell: HierarchyInspectorTableViewCell {
    
    var viewModel: HierarchyInspectorSnapshotCellViewModelProtocol? {
        didSet {
            textLabel?.text       = viewModel?.title
            detailTextLabel?.text = viewModel?.subtitle
            imageView?.image      = viewModel?.image
            
            let depth = CGFloat(viewModel?.depth ?? 0)
            var margins = defaultLayoutMargins
            margins.leading += depth * 5
            
            directionalLayoutMargins = margins
            separatorInset = .insets(left: margins.leading, right: defaultLayoutMargins.trailing)
            
            contentView.alpha = viewModel?.isEnabled == true ? 1 : ElementInspector.appearance.disabledAlpha
            selectionStyle = viewModel?.isEnabled == true ? .default : .none
        }
    }
    
    override func setup() {
        super.setup()
        
        textLabel?.font = .preferredFont(forTextStyle: .footnote)
        textLabel?.numberOfLines = 2
        
        detailTextLabel?.numberOfLines = 0
        
        imageView?.tintColor = ElementInspector.appearance.textColor
        imageView?.clipsToBounds = true
        imageView?.backgroundColor = ElementInspector.appearance.quaternaryTextColor
        imageView?.contentMode = .center
        
        imageView?.layer.cornerRadius = ElementInspector.appearance.verticalMargins / 2
        if #available(iOS 13.0, *) {
            imageView?.layer.cornerCurve = .continuous
        }
    }
    
}
