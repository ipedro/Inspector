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

extension DefaultElementSizeLibrary {
    final class LayoutConstraintSizeSectionDataSource: NSObject, InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        typealias Axis = LayoutConstraintElement.Axis

        private let constraint: LayoutConstraintElement

        init(constraint: LayoutConstraintElement) {
            self.constraint = constraint
        }

        var axis: Axis { constraint.axis }

        var title: String { constraint.type.description }

        var subtitle: String? { constraint.underlyingConstraint?.safeIdentifier }

        var customClass: InspectorElementSectionView.Type? {
            InspectorElementLayoutConstraintSectionView.self
        }

        var titleAccessoryBinding: InspectorPropertyBinding? {
            guard let underlyingConstraint = constraint.underlyingConstraint else { return nil }
            return .init(
                descriptor: .init(
                    id: "installed",
                    title: "Installed",
                    kind: .toggle,
                    value: .bool,
                    editability: .editable
                ),
                read: { .bool(underlyingConstraint.isActive) },
                write: { newValue in
                    guard case let .bool(isActive) = newValue else { return }
                    underlyingConstraint.isActive = isActive
                }
            )
        }

        private enum Property: String, Swift.CaseIterable {
            case firstItem = "First Item"
            case relation = "Relation"
            case secondItem = "Second Item"
            case spacer0
            case constant = "Constant"
            case priority = "Priority"
            case multiplier = "Multiplier"
            case spacer1
            case identifier = "Identifier"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let underlyingConstraint = constraint.underlyingConstraint else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .constant:
                    return .init(
                        descriptor: .init(
                            id: "constant",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(step: 1, isDecimal: true)),
                            editability: .editable
                        ),
                        read: { .number(Double(underlyingConstraint.constant)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            underlyingConstraint.constant = CGFloat(value)
                        }
                    )
                case .spacer0, .spacer1:
                    return .init(
                        descriptor: .init(id: property.rawValue, title: "", kind: .separator, value: .none, editability: .readOnly),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .multiplier:
                    return .init(
                        descriptor: .init(
                            id: "multiplier",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(step: 0.1, isDecimal: true)),
                            editability: .readOnly
                        ),
                        read: { .number(Double(underlyingConstraint.multiplier)) },
                        write: nil,
                        refreshHint: .none
                    )
                case .identifier:
                    return .init(
                        descriptor: .init(
                            id: "identifier",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: constraint.underlyingConstraint?.safeIdentifier ?? property.rawValue, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .string(underlyingConstraint.safeIdentifier) },
                        write: { newValue in
                            guard case let .string(identifier) = newValue else { return }
                            underlyingConstraint.identifier = identifier
                        }
                    )
                case .priority:
                    return .init(
                        descriptor: .init(
                            id: "priority",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(min: Double(UILayoutPriority.fittingSizeLevel.rawValue), max: Double(UILayoutPriority.required.rawValue), step: 50, isDecimal: false)),
                            editability: .editable
                        ),
                        read: { .number(Double(underlyingConstraint.priority.rawValue)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            underlyingConstraint.priority = .init(Float(value))
                        }
                    )
                case .firstItem:
                    return .init(
                        descriptor: .init(
                            id: "first-item",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: [.init(id: "0", title: constraint.first.displayName)], allowsNil: true)),
                            editability: .readOnly,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .selection(0) },
                        write: nil,
                        refreshHint: .none
                    )
                case .relation:
                    return .init(
                        descriptor: .init(
                            id: "relation",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: NSLayoutConstraint.Relation.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                            editability: .readOnly
                        ),
                        read: { .selection(NSLayoutConstraint.Relation.allCases.firstIndex(of: underlyingConstraint.relation)) },
                        write: nil,
                        refreshHint: .none
                    )
                case .secondItem:
                    guard let second = constraint.second else { return nil }
                    return .init(
                        descriptor: .init(
                            id: "second-item",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: [.init(id: "0", title: second.displayName)], allowsNil: true)),
                            editability: .readOnly,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .selection(0) },
                        write: nil,
                        refreshHint: .none
                    )
                }
            }
        }
    }
}
