//
//  ImagePreviewControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol ImagePreviewControlDelegate: AnyObject {
    func imagePreviewControlDidTap(_ imagePreviewControl: ImagePreviewControl)
}

final class ImagePreviewControl: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: ImagePreviewControlDelegate?
    
    var selectedImage: UIImage? {
        didSet {
            didUpdateImage()
        }
    }
    
    func updateSelectedImage(_ image: UIImage?) {
        selectedImage = image
        
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
        $0.backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
        
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
        
        $0.heightAnchor.constraint(equalToConstant: ElementInspector.appearance.horizontalMargins).isActive = true
        
        $0.installView(imageView)
    }
    
    private lazy var imageView = UIImageView(image: selectedImage).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var imageNameLabel = UILabel(
        .textStyle(.footnote),
        .textColor(ElementInspector.appearance.textColor),
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
        self.selectedImage = image
        
        super.init(title: title)
    }
    
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
        imageView.image = selectedImage
        
        guard let selectedImage = selectedImage else {
            imageNameLabel.text = "No Image"
            return
        }
        
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            guard selectedImage.isSymbolImage == false else {
                imageNameLabel.text = "Vector \(selectedImage.size.debugDescription)"
                return
            }
        }
        #endif
        
        imageNameLabel.text = "\(selectedImage.size.debugDescription) @\(Int(selectedImage.scale))x"
    }
    
    @objc private func tapImage() {
        delegate?.imagePreviewControlDidTap(self)
    }
}
