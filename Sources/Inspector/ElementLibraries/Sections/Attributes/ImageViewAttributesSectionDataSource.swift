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

extension DefaultElementAttributesLibrary {
    final class ImageViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Image"

        private weak var imageView: UIImageView?

        init?(with object: NSObject) {
            guard let imageView = object as? UIImageView else { return nil }

            self.imageView = imageView
        }

        private enum Property: String, Swift.CaseIterable {
            case image = "Image"
            case animationImages = "Animation Images"
            case highlightedImage = "Highlighted Image"
            case highlightedAnimationImages = "Highlighted Animation Images"
            case separator = "Separator"
            case isHighlighted = "Highlighted"
            case adjustsImageSizeForAccessibilityContentSizeCategory = "Adjusts Image Size"
        }

        private func imagesPickers(for images: [UIImage]) -> [InspectorElementProperty] {
            images.enumerated().map { offset, image in
                .imagePicker(
                    title: "#\(offset)",
                    axis: .horizontal,
                    image: { image },
                    handler: .none
                )
            }
        }

        var properties: [InspectorElementProperty] {
            guard let imageView = imageView else { return [] }

            return Property.allCases
                .flatMap { property -> [InspectorElementProperty] in
                    switch property {
                    case .separator:
                        return [.separator]

                    case .image:
                        return [.imagePicker(
                            title: property.rawValue,
                            image: { imageView.image }
                        ) { image in
                            imageView.image = image
                        }]

                    case .animationImages:
                        guard let animationImages = imageView.animationImages else { return [] }
                        return [.group(title: property.rawValue, subtitle: "\(animationImages.count) images")] + imagesPickers(for: animationImages) + [.separator]

                    case .highlightedImage:
                        return [.imagePicker(
                            title: property.rawValue,
                            image: { imageView.highlightedImage }
                        ) { highlightedImage in
                            imageView.highlightedImage = highlightedImage
                        }]

                    case .highlightedAnimationImages:
                        guard let highlightedAnimationImages = imageView.highlightedAnimationImages else { return [] }
                        return [.group(title: property.rawValue, subtitle: "\(highlightedAnimationImages.count) images")] + imagesPickers(for: highlightedAnimationImages) + [.separator]

                    case .isHighlighted:
                        return [.switch(
                            title: property.rawValue,
                            isOn: { imageView.isHighlighted }
                        ) { isHighlighted in
                            imageView.isHighlighted = isHighlighted
                        }]

                    case .adjustsImageSizeForAccessibilityContentSizeCategory:
                        return [.switch(
                            title: property.rawValue,
                            isOn: { imageView.adjustsImageSizeForAccessibilityContentSizeCategory }
                        ) { adjustsImageSizeForAccessibilityContentSizeCategory in
                            imageView.adjustsImageSizeForAccessibilityContentSizeCategory = adjustsImageSizeForAccessibilityContentSizeCategory
                        }]
                    }
                }
        }
    }
}
