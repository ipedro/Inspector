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

extension UIViewElementLibrary {
    final class UIImageViewInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case image = "Image"
            case highlightedImage = "Highlighted Image"
            case separator = "Separator"
            case isHighlighted = "Highlighted"
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
        
        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
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
