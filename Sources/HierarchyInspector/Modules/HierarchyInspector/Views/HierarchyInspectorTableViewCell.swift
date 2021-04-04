//
//  HierarchyInspectorTableViewCell.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

final class HierarchyInspectorTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundView = UIView()
        
        backgroundColor = nil
        
        textLabel?.font = .preferredFont(forTextStyle: .callout)
        textLabel?.textColor = ElementInspector.appearance.textColor
        
        selectedBackgroundView = UIView().then {
            $0.backgroundColor = ElementInspector.appearance.tintColor
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
