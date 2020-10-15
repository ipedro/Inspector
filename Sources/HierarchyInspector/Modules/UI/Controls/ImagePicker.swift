//
//  ImagePicker.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol ImagePickerDelegate: AnyObject {
    func imagePickerDidTap(_ imagePicker: ImagePicker)
}

final class ImagePicker: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: ImagePickerDelegate?
    
    var selectedImage: UIImage? {
        didSet {
            didUpdateImage()
            
            sendActions(for: .valueChanged)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            tapGestureRecognizer.isEnabled = isEnabled
            accessoryControl.isEnabled = isEnabled
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImage))
    
    private lazy var imageDisplayControl = ImageDisplayControl().then {
        $0.image = selectedImage
        
        $0.heightAnchor.constraint(equalToConstant: 24).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 2).isActive = true
    }
    
    private lazy var imageNameLabel = UILabel(.footnote).then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private(set) lazy var accessoryControl = ViewInspectorControlAccessoryControl().then {
        $0.addGestureRecognizer(tapGestureRecognizer)
        
        $0.contentView.spacing = ElementInspector.appearance.verticalMargins
        
        $0.contentView.addArrangedSubview(imageNameLabel)
        
        $0.contentView.addArrangedSubview(imageDisplayControl)
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
        
        contentView.addArrangedSubview(accessoryControl)
        
        didUpdateImage()
    }
    
    private func didUpdateImage() {
        imageDisplayControl.image = selectedImage
        
        guard let selectedImage = selectedImage else {
            imageNameLabel.text = "No Image"
            return
        }
        
        imageNameLabel.text = selectedImage.size.debugDescription
    }
    
    @objc private func tapImage() {
        delegate?.imagePickerDidTap(self)
    }
}

extension ColorPicker {
    
}

final class ImageDisplayControl: BaseControl {
    
    var image: UIImage? {
        didSet {
            imageVIew.image = image
        }
    }
    
    private lazy var imageVIew = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = ElementInspector.appearance.tertiaryTextColor
        
        layer.cornerRadius = 5
        
        layer.masksToBounds = true
        
        installView(imageVIew)
    }
    
    override func draw(_ rect: CGRect) {
        IconKit.drawColorGrid(frame: bounds, resizing: .aspectFill)
    }
}
