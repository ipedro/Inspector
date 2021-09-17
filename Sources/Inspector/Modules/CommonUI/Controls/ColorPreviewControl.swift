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

protocol ColorPreviewControlDelegate: AnyObject {
    func colorPreviewControlDidTap(_ colorPreviewControl: ColorPreviewControl)
}

final class ColorPreviewControl: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: ColorPreviewControlDelegate?
    
    var selectedColor: UIColor? {
        didSet {
            updateViews()
        }
    }
    
    func updateSelectedColor(_ color: UIColor?) {
        selectedColor = color
        
        sendActions(for: .valueChanged)
    }
    
    override var isEnabled: Bool {
        didSet {
            tapGestureRecognizer.isEnabled = isEnabled
            accessoryControl.isEnabled = isEnabled
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapColor))
    
    private lazy var colorDisplayControl = ColorDisplayControl().then {
        $0.color = selectedColor
        
        $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 2).isActive = true
    }
    
    private lazy var colorDisplayLabel = UILabel(
        .textStyle(.footnote),
        .textColor(Inspector.configuration.colorStyle.textColor),
        .huggingPriority(.defaultHigh, for: .horizontal)
    )
    
    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.addGestureRecognizer(tapGestureRecognizer)
        $0.contentView.addArrangedSubview(colorDisplayLabel)
        $0.contentView.addArrangedSubview(colorDisplayControl)
    }
    
    // MARK: - Init
    
    init(title: String?, color: UIColor?) {
        selectedColor = color
        
        super.init(title: title)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(accessoryControl)
        
        #if swift(>=5.3)
        if #available(iOS 14.0, *) {
            colorDisplayControl.isEnabled = true
        }
        #else
        accessoryControl.isUserInteractionEnabled = false
        colorDisplayLabel.textColor = Inspector.configuration.colorStyle.tintColor
        accessoryControl.backgroundColor = nil
        var margins = accessoryControl.contentView.directionalLayoutMargins
        margins.leading = 0
        margins.trailing = 0
        
        accessoryControl.contentView.directionalLayoutMargins = margins
        #endif
        
        updateViews()
    }
    
    private func updateViews() {
        colorDisplayControl.color = selectedColor
        
        colorDisplayLabel.text = selectedColor?.hexDescription ?? "No color"
    }
    
    @objc private func tapColor() {
        delegate?.colorPreviewControlDidTap(self)
    }
}

extension ColorPreviewControl {
    final class ColorDisplayControl: BaseControl {
        var color: UIColor? {
            didSet {
                colorBackgroundView.backgroundColor = color
            }
        }
        
        private lazy var colorBackgroundView = UIView(
            .backgroundColor(nil),
            .isUserInteractionEnabled(false)
        )
        
        override func setup() {
            super.setup()
            
            backgroundColor = Inspector.configuration.colorStyle.tertiaryTextColor
            
            layer.cornerRadius = 5
            
            layer.masksToBounds = true
            
            installView(colorBackgroundView)
        }
        
        override func draw(_ rect: CGRect) {
            IconKit.drawColorGrid(frame: bounds, resizing: .aspectFill)
        }
    }
}
