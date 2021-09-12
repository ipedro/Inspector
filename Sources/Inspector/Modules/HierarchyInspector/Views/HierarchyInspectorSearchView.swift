//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
    
    private(set) lazy var textField = UITextField(
        .clearButtonMode(.whileEditing),
        .textStyle(.title2),
        .textColor(ElementInspector.appearance.textColor),
        .attributedPlaceholder(
            NSAttributedString(
                Texts.hierarchySearch,
                .foregroundColor(ElementInspector.appearance.tertiaryTextColor),
                .textStyle(.title2)
            )
        )
    )
    
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
        contentView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
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
