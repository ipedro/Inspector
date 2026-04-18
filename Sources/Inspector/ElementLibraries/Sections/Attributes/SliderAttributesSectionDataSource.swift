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
    final class SliderAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Slider"

        private weak var slider: UISlider?

        init?(with object: NSObject) {
            guard let slider = object as? UISlider else { return nil }

            self.slider = slider
        }

        private enum Property: String, Swift.CaseIterable {
            case value = "Value"
            case minimumValue = "Minimum"
            case maximumValue = "Maximum"
            case groupImages = "Images"
            case minimumValueImage = "Min Image"
            case maximumValueImage = "Max Image"
            case groupColors = "Colors"
            case minimumTrackTintColor = "Min Track"
            case maxTrack = "Max Track"
            case thumbTintColor = "Thumb Tint"
            case groupEvent = "Event"
            case isContinuous = "Continuous updates"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let slider else { return [] }
            let stepValueProvider = { max(0.01, (slider.maximumValue - slider.minimumValue) / 100) }

            return Property.allCases.compactMap { property in
                switch property {
                case .value:
                    .init(
                        descriptor: .init(
                            id: "value",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(
                                min: Double(min(slider.minimumValue, slider.maximumValue)),
                                max: Double(max(slider.minimumValue, slider.maximumValue)),
                                step: Double(stepValueProvider()),
                                isDecimal: true
                            )),
                            editability: .editable
                        ),
                        read: { .number(Double(slider.value)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            slider.value = Float(value)
                            slider.sendActions(for: .valueChanged)
                        }
                    )

                case .minimumValue:
                    .init(
                        descriptor: .init(
                            id: "minimum-value",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(
                                min: 0,
                                max: Double(max(0, slider.maximumValue)),
                                step: Double(stepValueProvider()),
                                isDecimal: true
                            )),
                            editability: .editable
                        ),
                        read: { .number(Double(slider.minimumValue)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            slider.minimumValue = Float(value)
                        }
                    )

                case .maximumValue:
                    .init(
                        descriptor: .init(
                            id: "maximum-value",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(
                                min: Double(slider.minimumValue),
                                step: Double(stepValueProvider()),
                                isDecimal: true
                            )),
                            editability: .editable
                        ),
                        read: { .number(Double(slider.maximumValue)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            slider.maximumValue = Float(value)
                        }
                    )

                case .groupImages:
                    .init(
                        descriptor: .init(
                            id: "group-images",
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )

                case .minimumValueImage:
                    .init(
                        descriptor: .init(
                            id: "minimum-value-image",
                            title: property.rawValue,
                            kind: .preview,
                            value: .none,
                            editability: .editable
                        ),
                        read: { .image(slider.minimumValueImage) },
                        write: { newValue in
                            guard case let .image(image) = newValue else { return }
                            slider.minimumValueImage = image
                        }
                    )

                case .maximumValueImage:
                    .init(
                        descriptor: .init(
                            id: "maximum-value-image",
                            title: property.rawValue,
                            kind: .preview,
                            value: .none,
                            editability: .editable
                        ),
                        read: { .image(slider.maximumValueImage) },
                        write: { newValue in
                            guard case let .image(image) = newValue else { return }
                            slider.maximumValueImage = image
                        }
                    )

                case .groupColors:
                    .init(
                        descriptor: .init(
                            id: "group-colors",
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )

                case .minimumTrackTintColor:
                    .init(
                        descriptor: .init(
                            id: "minimum-track-tint-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(slider.minimumTrackTintColor) },
                        write: { newValue in
                            guard case let .color(color) = newValue else { return }
                            slider.minimumTrackTintColor = color
                        }
                    )

                case .maxTrack:
                    .init(
                        descriptor: .init(
                            id: "maximum-track-tint-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(slider.maximumTrackTintColor) },
                        write: { newValue in
                            guard case let .color(color) = newValue else { return }
                            slider.maximumTrackTintColor = color
                        }
                    )

                case .thumbTintColor:
                    .init(
                        descriptor: .init(
                            id: "thumb-tint-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(slider.thumbTintColor) },
                        write: { newValue in
                            guard case let .color(color) = newValue else { return }
                            slider.thumbTintColor = color
                        }
                    )

                case .groupEvent:
                    .init(
                        descriptor: .init(
                            id: "group-event",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )

                case .isContinuous:
                    .init(
                        descriptor: .init(
                            id: "is-continuous",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(slider.isContinuous) },
                        write: { newValue in
                            guard case let .bool(isContinuous) = newValue else { return }
                            slider.isContinuous = isContinuous
                        }
                    )
                }
            }
        }
    }
}
