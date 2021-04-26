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

protocol OptionListControlDelegate: AnyObject {
    func optionListControlDidTap(_ optionListControl: OptionListControl)
}

final class OptionListControl: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: OptionListControlDelegate?
    
    override var isEnabled: Bool {
        didSet {
            tapGestureRecognizer.isEnabled = isEnabled
            icon.isHidden = isEnabled == false
            accessoryControl.isEnabled = isEnabled
        }
    }
    
    private lazy var icon = Icon(
        .chevronUpDown,
        color: ElementInspector.appearance.secondaryTextColor,
        size: CGSize(width: 14, height: 14)
    )
    
    private lazy var valueLabel = UILabel(
        .textStyle(.footnote),
        .textColor(ElementInspector.appearance.textColor),
        .adjustsFontSizeToFitWidth(true),
        .minimumScaleFactor(0.6)
    )
    
    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.contentView.addArrangedSubviews(valueLabel, icon)
        $0.contentView.alignment = .center
        $0.contentView.spacing = ElementInspector.appearance.verticalMargins
        $0.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    
    // MARK: - Init
    
    let options: [Swift.CustomStringConvertible]
    
    let emptyTitle: String
    
    var selectedIndex: Int? {
        didSet {
            updateViews()
        }
    }
    
    init(
        title: String?,
        options: [Swift.CustomStringConvertible],
        emptyTitle: String,
        selectedIndex: Int? = nil
    ) {
        self.options = options
        
        self.selectedIndex = selectedIndex
        
        self.emptyTitle = emptyTitle

        super.init(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(accessoryControl)
        
        accessoryControl.widthAnchor.constraint(greaterThanOrEqualTo: contentContainerView.widthAnchor, multiplier: 1 / 2).isActive = true
        
        tintColor = valueLabel.textColor
        
        updateViews()
    }
    
    func updateSelectedIndex(_ selectedIndex: Int?) {
        self.selectedIndex = selectedIndex
        
        sendActions(for: .valueChanged)
    }
    
    private func updateViews() {
        
        guard let selectedIndex = selectedIndex else {
            valueLabel.text = emptyTitle
            return
        }
        
        valueLabel.text = options[selectedIndex].description
    }
    
    @objc private func tap() {
        delegate?.optionListControlDidTap(self)
    }
}
