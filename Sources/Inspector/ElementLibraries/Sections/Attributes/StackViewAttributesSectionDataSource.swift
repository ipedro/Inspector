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
    final class StackViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Stack View"

        private weak var stackView: UIStackView?

        init?(with object: NSObject) {
            guard let stackView = object as? UIStackView else { return nil }

            self.stackView = stackView
        }

        private enum Property: String, Swift.CaseIterable {
            case axis = "Axis"
            case alignment = "Alignment"
            case distribution = "Distribution"
            case spacing = "Spacing"
            case isLayoutMarginsRelativeArrangement = "Layout Margins Relative"
            case isBaselineRelativeArrangement = "Baseline Relative"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let stackView else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .axis:
                    .init(
                        descriptor: .init(
                            id: "axis",
                            title: property.rawValue,
                            kind: .textButtons,
                            value: .selection(
                                .init(options: NSLayoutConstraint.Axis.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(NSLayoutConstraint.Axis.allCases.firstIndex(of: stackView.axis)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let axis = NSLayoutConstraint.Axis.allCases[newIndex]

                            stackView.axis = axis
                        }
                    )
                case .alignment:
                    .init(
                        descriptor: .init(
                            id: "alignment",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIStackView.Alignment.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIStackView.Alignment.allCases.firstIndex(of: stackView.alignment)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let alignment = UIStackView.Alignment.allCases[newIndex]

                            stackView.alignment = alignment
                        }
                    )
                case .distribution:
                    .init(
                        descriptor: .init(
                            id: "distribution",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIStackView.Distribution.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIStackView.Distribution.allCases.firstIndex(of: stackView.distribution)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let distribution = UIStackView.Distribution.allCases[newIndex]

                            stackView.distribution = distribution
                        }
                    )
                case .spacing:
                    .init(
                        descriptor: .init(
                            id: "spacing",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(min: 0, step: 1, isDecimal: true)),
                            editability: .editable
                        ),
                        read: { .number(Double(stackView.spacing)) },
                        write: { newValue in
                            guard case let .number(spacing) = newValue else { return }
                            stackView.spacing = CGFloat(spacing)
                        }
                    )
                case .isBaselineRelativeArrangement:
                    .init(
                        descriptor: .init(
                            id: "is-baseline-relative-arrangement",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(stackView.isBaselineRelativeArrangement) },
                        write: { newValue in
                            guard case let .bool(isBaselineRelativeArrangement) = newValue else { return }
                            stackView.isBaselineRelativeArrangement = isBaselineRelativeArrangement
                        }
                    )
                case .isLayoutMarginsRelativeArrangement:
                    .init(
                        descriptor: .init(
                            id: "is-layout-margins-relative-arrangement",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(stackView.isLayoutMarginsRelativeArrangement) },
                        write: { newValue in
                            guard case let .bool(isLayoutMarginsRelativeArrangement) = newValue else { return }
                            stackView.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
                        }
                    )
                }
            }
        }
    }
}
