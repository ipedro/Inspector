//
//  HierarchyInspectorHeaderView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.04.21.
//

import UIKit

final class HierarchyInspectorHeaderView: UITableViewHeaderFooterView {
    
    var title: String? = nil {
        didSet {
            titleLabel.text = title
            
            switch title {
            case .none:
                titleLabel.isHidden = true
                stackView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
                
            case .some:
                titleLabel.isHidden = false
                stackView.directionalLayoutMargins = .margins(
                    leading: ElementInspector.appearance.horizontalMargins,
                    bottom: stackView.spacing / 2,
                    trailing: ElementInspector.appearance.horizontalMargins
                )
            }
        }
    }
    
    private(set) lazy var separatorView = SeparatorView(
        color: ElementInspector.appearance.tertiaryTextColor
    )
    
    private lazy var stackView = UIStackView.vertical(
        arrangedSubviews: [
            separatorView,
            titleLabel
        ],
        spacing: ElementInspector.appearance.verticalMargins
    )
    
    private(set) lazy var titleLabel = UILabel(
        .caption1,
        textColor: ElementInspector.appearance.tertiaryTextColor
    ).then {
        $0.font = $0.font.bold()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        backgroundView = UIView()
        
        contentView.installView(stackView)
    }
    
}
