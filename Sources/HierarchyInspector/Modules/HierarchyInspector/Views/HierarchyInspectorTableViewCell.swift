//
//  HierarchyInspectorTableViewCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

final class HierarchyInspectorTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let defaultLayoutMargins: NSDirectionalEdgeInsets = .allMargins(ElementInspector.appearance.horizontalMargins)
    
    var viewModel: HierarchyInspectorCellViewModelProtocol? {
        didSet {
            textLabel?.text         = viewModel?.title
            textLabel?.font         = viewModel?.titleFont
            detailTextLabel?.text   = viewModel?.subtitle
            imageView?.image        = viewModel?.image
            
            let depth = CGFloat(viewModel?.depth ?? 0)
            var margins = defaultLayoutMargins
            margins.leading += depth * 5
            
            directionalLayoutMargins = margins
        }
    }
    
    func setup() {
        backgroundView = UIView()
        
        backgroundColor = nil
        
        imageView?.tintColor = ElementInspector.appearance.textColor
        imageView?.layer.cornerRadius = 6
        imageView?.clipsToBounds = true
        imageView?.backgroundColor = ElementInspector.appearance.quaternaryTextColor
        imageView?.contentMode = .center
        
        detailTextLabel?.textColor = ElementInspector.appearance.secondaryTextColor
        detailTextLabel?.numberOfLines = 2
        
        let widthAnchor = imageView?.widthAnchor.constraint(equalToConstant: 32).then {
            $0.priority = .defaultHigh
        }
        
        let heightAnchor = imageView?.heightAnchor.constraint(equalToConstant: 32).then {
            $0.priority = .defaultHigh
        }
        
        widthAnchor?.isActive = true
        heightAnchor?.isActive = true
        
        textLabel?.textColor = ElementInspector.appearance.textColor
        
        selectedBackgroundView = UIView().then {
            let colorView = UIView()
            colorView.backgroundColor = ElementInspector.appearance.tintColor
            colorView.clipsToBounds = true
            colorView.layer.cornerRadius = 7
            
            $0.installView(
                colorView,
                .margins(
                    horizontal: ElementInspector.appearance.verticalMargins,
                    vertical: .zero
                )
            )
        }
    }
    
    func maskCellFromTop(margin: CGFloat) {
        layer.mask = visibilityMaskWithLocation(location: margin / frame.size.height)
        layer.masksToBounds = true
    }
    
    func visibilityMaskWithLocation(location: CGFloat) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = bounds
        mask.locations = [
            NSNumber(value: Float(location)),
            NSNumber(value: Float(location))
        ]
        mask.colors = [
            UIColor(white: 1, alpha: 0).cgColor,
            UIColor(white: 1, alpha: 1).cgColor
        ]
        
        return mask
    }
}
