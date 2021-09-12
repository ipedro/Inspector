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

class BaseFormControl: BaseControl {
    private(set) lazy var titleLabel = UILabel(
        .textStyle(.footnote),
        .huggingPriority(.fittingSizeLevel, for: .horizontal),
        .textColor(ElementInspector.appearance.textColor)
    )
    
    override var isEnabled: Bool {
        didSet {
            titleLabel.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    private(set) lazy var contentContainerView = UIStackView.horizontal(
        .arrangedSubviews(
            titleLabel,
            contentView
        ),
        .spacing(defaultSpacing)
    )
    
    private lazy var containerView = UIStackView.vertical(
        .arrangedSubviews(contentContainerView),
        .spacing(defaultSpacing),
        .directionalLayoutMargins(vertical: defaultSpacing)
    )
    
    private lazy var separator = SeparatorView().then {
        $0.alpha = 0.5
    }
    
    var isShowingSeparator: Bool {
        get {
            separator.isHidden == false
        }
        set {
            separator.isSafelyHidden = !newValue
        }
    }
    
    var axis: NSLayoutConstraint.Axis {
        get {
            contentContainerView.axis
        }
        set {
            contentContainerView.axis = newValue
        }
    }
    
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    init(title: String?, isEnabled: Bool = true, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.title = title
        
        self.isEnabled = isEnabled
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setup() {
        super.setup()
        
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        tintColor = .systemPurple
        
        installView(containerView)
        
        installSeparator()
    }
    
    private func installSeparator() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separator)
    
        separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
