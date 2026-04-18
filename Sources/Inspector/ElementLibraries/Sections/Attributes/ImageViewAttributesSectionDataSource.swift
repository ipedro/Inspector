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

import InspectorContract
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

        private func imageBindings(for images: [UIImage], idPrefix: String) -> [InspectorPropertyBinding] {
            images.enumerated().map { offset, image in
                .init(
                    descriptor: .init(
                        id: "\(idPrefix)-\(offset)",
                        title: "#\(offset)",
                        kind: .preview,
                        value: .none,
                        editability: .readOnly,
                        presentation: .init(axis: .horizontal)
                    ),
                    read: { .image(image) },
                    write: nil,
                    refreshHint: .none
                )
            }
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let imageView else { return [] }

            return Property.allCases.flatMap { property -> [InspectorPropertyBinding] in
                switch property {
                case .separator:
                    return [
                        .init(
                            descriptor: .init(id: "separator", title: "", kind: .separator, value: .none, editability: .readOnly),
                            read: { .none },
                            write: nil,
                            refreshHint: .none
                        )
                    ]

                case .image:
                    return [
                        .init(
                            descriptor: .init(id: "image", title: property.rawValue, kind: .preview, value: .none, editability: .editable),
                            read: { .image(imageView.image) },
                            write: { newValue in
                                guard case let .image(image) = newValue else { return }
                                imageView.image = image
                            }
                        )
                    ]

                case .animationImages:
                    guard let animationImages = imageView.animationImages else { return [] }
                    return [
                        .init(
                            descriptor: .init(
                                id: "animation-images-group",
                                title: property.rawValue,
                                kind: .group,
                                value: .none,
                                editability: .readOnly,
                                presentation: .init(subtitle: "\(animationImages.count) images")
                            ),
                            read: { .none },
                            write: nil,
                            refreshHint: .none
                        )
                    ] + imageBindings(for: animationImages, idPrefix: "animation-image") + [
                        .init(
                            descriptor: .init(id: "animation-images-separator", title: "", kind: .separator, value: .none, editability: .readOnly),
                            read: { .none },
                            write: nil,
                            refreshHint: .none
                        )
                    ]

                case .highlightedImage:
                    return [
                        .init(
                            descriptor: .init(id: "highlighted-image", title: property.rawValue, kind: .preview, value: .none, editability: .editable),
                            read: { .image(imageView.highlightedImage) },
                            write: { newValue in
                                guard case let .image(image) = newValue else { return }
                                imageView.highlightedImage = image
                            }
                        )
                    ]

                case .highlightedAnimationImages:
                    guard let highlightedAnimationImages = imageView.highlightedAnimationImages else { return [] }
                    return [
                        .init(
                            descriptor: .init(
                                id: "highlighted-animation-images-group",
                                title: property.rawValue,
                                kind: .group,
                                value: .none,
                                editability: .readOnly,
                                presentation: .init(subtitle: "\(highlightedAnimationImages.count) images")
                            ),
                            read: { .none },
                            write: nil,
                            refreshHint: .none
                        )
                    ] + imageBindings(for: highlightedAnimationImages, idPrefix: "highlighted-animation-image") + [
                        .init(
                            descriptor: .init(id: "highlighted-animation-images-separator", title: "", kind: .separator, value: .none, editability: .readOnly),
                            read: { .none },
                            write: nil,
                            refreshHint: .none
                        )
                    ]

                case .isHighlighted:
                    return [
                        .init(
                            descriptor: .init(id: "is-highlighted", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                            read: { .bool(imageView.isHighlighted) },
                            write: { newValue in
                                guard case let .bool(isHighlighted) = newValue else { return }
                                imageView.isHighlighted = isHighlighted
                            }
                        )
                    ]

                case .adjustsImageSizeForAccessibilityContentSizeCategory:
                    return [
                        .init(
                            descriptor: .init(
                                id: "adjusts-image-size-for-accessibility-content-size-category",
                                title: property.rawValue,
                                kind: .toggle,
                                value: .bool,
                                editability: .editable
                            ),
                            read: { .bool(imageView.adjustsImageSizeForAccessibilityContentSizeCategory) },
                            write: { newValue in
                                guard case let .bool(isEnabled) = newValue else { return }
                                imageView.adjustsImageSizeForAccessibilityContentSizeCategory = isEnabled
                            }
                        )
                    ]
                }
            }
        }
    }
}
