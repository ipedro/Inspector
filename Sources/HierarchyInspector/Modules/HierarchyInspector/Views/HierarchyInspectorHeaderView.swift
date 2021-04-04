//
//  HierarchyInspectorHeaderView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.04.21.
//

import UIKit

final class HierarchyInspectorHeaderView: BaseView {
    
    var title: String? = nil {
        didSet {
            textLabel.text = title
            
            switch title {
            case .none:
                textLabel.isHidden = true
                contentView.directionalLayoutMargins = ElementInspector.appearance.margins
                
            case .some:
                textLabel.isHidden = false
                contentView.directionalLayoutMargins = .horizontalMargins(ElementInspector.appearance.horizontalMargins)
            }
        }
    }
    
    private(set) lazy var separatorView = SeparatorView(
        color: ElementInspector.appearance.tertiaryTextColor
    )
    
    private(set) lazy var textLabel = UILabel(
        .caption1,
        textColor: ElementInspector.appearance.tertiaryTextColor
    ).then {
        $0.font = $0.font.bold()
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(separatorView)
        contentView.addArrangedSubview(textLabel)
        contentView.spacing = ElementInspector.appearance.verticalMargins
    }
    
}
