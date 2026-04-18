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
    final class SegmentedControlAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Segmented Control"

        private weak var segmentedControl: UISegmentedControl?

        init?(with object: NSObject) {
            guard let segmentedControl = object as? UISegmentedControl else { return nil }

            self.segmentedControl = segmentedControl

            selectedSegment = segmentedControl.numberOfSegments == 0 ? nil : 0
        }

        private var selectedSegment: Int?

        private enum Property: String, Swift.CaseIterable {
            case selectedSegmentTintColor = "Selected Tint"
            case isMomentary = "Momentary"
            case isSpringLoaded = "Spring Loaded"
            case groupSegment = "Segment Group"
            case segmentPicker = "Segment"
            case segmentTitle = "Title"
            case segmentImage = "Image"
            case segmentIsEnabled = "Enabled"
            case segmentIsSelected = "Selected"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let segmentedControl else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .selectedSegmentTintColor:
                    return .init(
                        descriptor: .init(
                            id: "selected-segment-tint-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(segmentedControl.selectedSegmentTintColor) },
                        write: { newValue in
                            guard case let .color(color) = newValue else { return }
                            segmentedControl.selectedSegmentTintColor = color
                        }
                    )
                case .isMomentary:
                    return .init(
                        descriptor: .init(
                            id: "is-momentary",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(segmentedControl.isMomentary) },
                        write: { newValue in
                            guard case let .bool(isMomentary) = newValue else { return }
                            segmentedControl.isMomentary = isMomentary
                        }
                    )
                case .isSpringLoaded:
                    return .init(
                        descriptor: .init(
                            id: "is-spring-loaded",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(segmentedControl.isSpringLoaded) },
                        write: { newValue in
                            guard case let .bool(isSpringLoaded) = newValue else { return }
                            segmentedControl.isSpringLoaded = isSpringLoaded
                        }
                    )
                case .groupSegment:
                    return .init(
                        descriptor: .init(
                            id: "segment-group",
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .segmentPicker:
                    return .init(
                        descriptor: .init(
                            id: "segment-picker",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: (0..<segmentedControl.numberOfSegments).map {
                                    .init(id: "\($0)", title: "Segment \($0)")
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { [weak self] in .selection(self?.selectedSegment) },
                        write: { [weak self] newValue in
                            guard case let .selection(selectedSegment) = newValue else { return }
                            self?.selectedSegment = selectedSegment
                        }
                    )
                case .segmentTitle:
                    return .init(
                        descriptor: .init(
                            id: "segment-title",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: property.rawValue, allowsNil: true)),
                            editability: .editable
                        ),
                        read: { [weak self] in
                            guard let selectedSegment = self?.selectedSegment else {
                                return .string(nil)
                            }

                            return .string(segmentedControl.titleForSegment(at: selectedSegment))
                        },
                        write: { [weak self] newValue in
                            guard case let .string(segmentTitle) = newValue else { return }
                            guard let selectedSegment = self?.selectedSegment else { return }

                            segmentedControl.setTitle(segmentTitle, forSegmentAt: selectedSegment)
                        }
                    )
                case .segmentImage:
                    return .init(
                        descriptor: .init(
                            id: "segment-image",
                            title: property.rawValue,
                            kind: .preview,
                            value: .none,
                            editability: .editable
                        ),
                        read: { [weak self] in
                            guard let selectedSegment = self?.selectedSegment else {
                                return .image(nil)
                            }

                            return .image(segmentedControl.imageForSegment(at: selectedSegment))
                        },
                        write: { [weak self] newValue in
                            guard case let .image(segmentImage) = newValue else { return }
                            guard let selectedSegment = self?.selectedSegment else { return }
                            segmentedControl.setImage(segmentImage, forSegmentAt: selectedSegment)
                        }
                    )
                case .segmentIsEnabled:
                    return .init(
                        descriptor: .init(
                            id: "segment-is-enabled",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { [weak self] in
                            guard let selectedSegment = self?.selectedSegment else {
                                return .bool(false)
                            }

                            return .bool(segmentedControl.isEnabledForSegment(at: selectedSegment))
                        },
                        write: { [weak self] newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            guard let selectedSegment = self?.selectedSegment else { return }
                            segmentedControl.setEnabled(isEnabled, forSegmentAt: selectedSegment)
                        }
                    )
                case .segmentIsSelected:
                    return .init(
                        descriptor: .init(
                            id: "segment-is-selected",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { [weak self] in .bool(self?.selectedSegment == segmentedControl.selectedSegmentIndex) },
                        write: { [weak self] newValue in
                            guard case let .bool(isSelected) = newValue else { return }
                            guard let selectedSegment = self?.selectedSegment else { return }

                            switch isSelected {
                            case true:
                                segmentedControl.selectedSegmentIndex = selectedSegment
                            case false:
                                segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
                            }
                        }
                    )
                }
            }
        }
    }
}
