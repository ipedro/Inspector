//
//  HierarchyInspectorSearchView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.04.21.
//

import UIKit

final class HierarchyInspectorSearchView: BaseView {
    
    private lazy var searchIcon = Icon(
        .search,
        color: ElementInspector.appearance.textColor.withAlphaComponent(0.73),
        size: CGSize(
            width: 19,
            height: 19
        )
    )
    
    private(set) lazy var textField = UITextField().then {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        
        $0.clearButtonMode = .whileEditing
        $0.font = font
        $0.textColor = ElementInspector.appearance.textColor
        $0.attributedPlaceholder = NSAttributedString(
            string: Texts.hierarchyInspector,
            attributes: [
                NSAttributedString.Key.foregroundColor: ElementInspector.appearance.tertiaryTextColor,
                NSAttributedString.Key.font: font
            ]
        )
    }
    
    private(set) lazy var separatorView = SeparatorView(
        thickness: 1,
        color: ElementInspector.appearance.tertiaryTextColor
    )
    
    override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }
    
    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        
        return textField.becomeFirstResponder()
    }
    
    override func setup() {
        super.setup()
        
        contentView.axis = .horizontal
        contentView.alignment = .center
        contentView.directionalLayoutMargins = ElementInspector.appearance.margins
        contentView.spacing = ElementInspector.appearance.horizontalMargins / 2
        
        contentView.addArrangedSubview(searchIcon)
        contentView.addArrangedSubview(textField)
        
        installView(separatorView, .margins(leading: .zero, bottom: .zero, trailing: .zero))
    }
    
}

// MARK: - APIs

extension HierarchyInspectorSearchView {
    
    var query: String? {
        textField.text
    }
    
    var hasText: Bool {
        textField.hasText
    }
    
    func insertText(_ text: String) {
        textField.insertText(text)
    }
    
    func deleteBackward() {
        textField.deleteBackward()
    }
}
