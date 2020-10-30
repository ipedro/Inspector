//
//  UIImageViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {

    final class UIImageViewSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        private enum Property: String, CaseIterable {
            case image                                               = "Image"
            case highlightedImage                                    = "Highlighted Image"
            case separator                                           = "Separator"
            case isHighlighted                                       = "Highlighted"
            case adjustsImageSizeForAccessibilityContentSizeCategory = "Adjusts Image Size"
        }
        
        let title = "Image"
        
        private(set) weak var imageView: UIImageView?
        
        init?(view: UIView) {
            guard let imageView = view as? UIImageView else {
                return nil
            }
            
            self.imageView = imageView
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let imageView = imageView else {
                return nil
            }

            switch property {
            
            case .separator:
                return .separator(title: property.rawValue)
                
            case .image:
                return .imagePicker(
                    title: property.rawValue,
                    image: { imageView.image }
                ) { image in
                    imageView.image = image
                }
                
            case .highlightedImage:
                return .imagePicker(
                    title: property.rawValue,
                    image: { imageView.highlightedImage }
                ) { highlightedImage in
                    imageView.highlightedImage = highlightedImage
                }
                
            case .isHighlighted:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { imageView.isHighlighted }
                ) { isHighlighted in
                    imageView.isHighlighted = isHighlighted
                }
                
            case .adjustsImageSizeForAccessibilityContentSizeCategory:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { imageView.adjustsImageSizeForAccessibilityContentSizeCategory }
                ) { adjustsImageSizeForAccessibilityContentSizeCategory in
                    imageView.adjustsImageSizeForAccessibilityContentSizeCategory = adjustsImageSizeForAccessibilityContentSizeCategory
                }
            }
        }
    }

}
