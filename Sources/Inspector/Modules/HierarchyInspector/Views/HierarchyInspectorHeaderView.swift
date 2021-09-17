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

final class HierarchyInspectorHeaderView: UITableViewHeaderFooterView {
    var title: String? {
        didSet {
            titleLabel.text = title
            
            switch title {
            case .none:
                titleLabel.isHidden = true
                stackView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
                
            case .some:
                titleLabel.isHidden = false
                stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
                    leading: ElementInspector.appearance.horizontalMargins,
                    bottom: stackView.spacing / 2,
                    trailing: ElementInspector.appearance.horizontalMargins
                )
            }
        }
    }
    
    var showSeparatorView: Bool {
        get { separatorView.alpha == 1 }
        set { separatorView.alpha = newValue ? 1 : 0.05 }
    }
    
    private(set) lazy var separatorView = SeparatorView(
        color: Inspector.configuration.colorStyle.tertiaryTextColor
    )
    
    private lazy var stackView = UIStackView.vertical(
        .arrangedSubviews(
            separatorView,
            titleLabel
        ),
        .spacing(ElementInspector.appearance.verticalMargins)
    )
    
    private(set) lazy var titleLabel = UILabel(
        .textStyle(.caption1, traits: .traitBold),
        .textColor(Inspector.configuration.colorStyle.tertiaryTextColor)
    )
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundView = UIView()
        
        contentView.installView(stackView)
    }
}
