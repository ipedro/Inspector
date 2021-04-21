//
//  HierarchyInspectorTableViewCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

class HierarchyInspectorTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let defaultLayoutMargins = NSDirectionalEdgeInsets(ElementInspector.appearance.horizontalMargins)
    
    func setup() {
        backgroundView = UIView()
        backgroundColor = nil
        
        // removes autoresize masks in favor of constraint based layout.
        // fixes a height calculation bug.
        installView(contentView)
        
        directionalLayoutMargins = defaultLayoutMargins
        separatorInset = UIEdgeInsets(left: defaultLayoutMargins.leading, right: defaultLayoutMargins.trailing)
        
        textLabel?.textColor = ElementInspector.appearance.textColor
        detailTextLabel?.textColor = ElementInspector.appearance.secondaryTextColor
        
        selectedBackgroundView = UIView().then {
            let colorView = BaseView(
                .clipsToBounds(true),
                .backgroundColor(ElementInspector.appearance.tintColor),
                .layerOptions(
                    .cornerRadius(ElementInspector.appearance.verticalMargins / 2)
                )
            )
            
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        layer.mask = nil
    }
}
