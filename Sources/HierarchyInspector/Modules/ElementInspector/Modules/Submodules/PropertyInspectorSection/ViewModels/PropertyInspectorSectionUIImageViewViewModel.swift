//
//  PropertyInspectorSectionUIImageViewViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class PropertyInspectorSectionUIImageViewViewModel: PropertyInspectorSectionViewModelProtocol {
    
    private enum Property: CaseIterable {
        case image
        case highlightedImage
        case separator
        case isHighlighted
        case adjustsImageSizeForAccessibilityContentSizeCategory
    }
    
    private(set) weak var imageView: UIImageView?
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
    private(set) lazy var title: String? = "Image"
    
    private(set) lazy var propertyInputs: [PropertyInspectorInput] = Property.allCases.compactMap {
        guard let imageView = imageView else {
            return nil
        }

        switch $0 {
        
        case .separator:
            return .separator
            
        case .image:
            return .imagePicker(
                title: "image",
                image: imageView.image
            ) { image in
                imageView.image = image
            }
            
        case .highlightedImage:
            return .imagePicker(
                title: "highlighted image",
                image: imageView.highlightedImage
            ) { highlightedImage in
                imageView.highlightedImage = highlightedImage
            }
            
        case .isHighlighted:
            return .toggleButton(
                title: "highlighted",
                isOn: imageView.isHighlighted
            ) { isHighlighted in
                imageView.isHighlighted = isHighlighted
            }
            
        case .adjustsImageSizeForAccessibilityContentSizeCategory:
            return .toggleButton(
                title: "adjusts image size",
                isOn: imageView.adjustsImageSizeForAccessibilityContentSizeCategory
            ) { adjustsImageSizeForAccessibilityContentSizeCategory in
                imageView.adjustsImageSizeForAccessibilityContentSizeCategory = adjustsImageSizeForAccessibilityContentSizeCategory
            }
        }
    }
}
