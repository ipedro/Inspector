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

protocol ImagePreviewControlDelegate: AnyObject {
    func imagePreviewControlDidTap(_ imagePreviewControl: ImagePreviewControl)
}

final class ImagePreviewControl: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: ImagePreviewControlDelegate?
    
    var image: UIImage? {
        didSet {
            didUpdateImage()
        }
    }
    
    func updateSelectedImage(_ image: UIImage?) {
        self.image = image
        
        sendActions(for: .valueChanged)
    }
    
    override var isEnabled: Bool {
        didSet {
            tapGestureRecognizer.isEnabled = isEnabled
            accessoryControl.isEnabled = isEnabled
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImage))
    
    private lazy var imageContainerView = UIImageView(image: IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero)).then {
        $0.backgroundColor = colorStyle.backgroundColor
        
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
        
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
        
        $0.heightAnchor.constraint(equalToConstant: ElementInspector.appearance.horizontalMargins).isActive = true
        
        $0.installView(imageView)
    }
    
    private lazy var imageView = UIImageView(image: image).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var imageNameLabel = UILabel(
        .textStyle(.footnote),
        .textColor(colorStyle.textColor),
        .huggingPriority(.defaultHigh, for: .horizontal)
    )
    
    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.addGestureRecognizer(tapGestureRecognizer)
        
        $0.clipsToBounds = true
        
        $0.contentView.addArrangedSubview(imageNameLabel)
        
        $0.contentView.addArrangedSubview(imageContainerView)
    }
    
    // MARK: - Init
    
    init(title: String?, image: UIImage?) {
        self.image = image
        
        super.init(title: title)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        
        contentView.addArrangedSubview(accessoryControl)
        
        didUpdateImage()
    }
    
    private func didUpdateImage() {
        imageView.image = image
        
        guard let image = image else {
            imageNameLabel.text = "None"
            return
        }
        
        imageNameLabel.text = image.assetName ?? image.sizeDesription
    }
    
    @objc private func tapImage() {
        delegate?.imagePreviewControlDidTap(self)
    }
}
