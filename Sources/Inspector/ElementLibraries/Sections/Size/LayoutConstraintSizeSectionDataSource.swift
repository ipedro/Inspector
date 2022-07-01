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

        var titleAccessoryProperty: InspectorElementProperty? {
            guard let underlyingConstraint = constraint.underlyingConstraint else { return nil }
            return .switch(
                title: "Installed",
                isOn: { underlyingConstraint.isActive },
                handler: { underlyingConstraint.isActive = $0 }
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

        var properties: [InspectorElementProperty] {
            guard let underlyingConstraint = constraint.underlyingConstraint else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .constant:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { underlyingConstraint.constant },
                        range: { -CGFloat.infinity...CGFloat.infinity },
                        stepValue: { 1 },
                        handler: { underlyingConstraint.constant = $0 }
                    )
                case .spacer0,
                     .spacer1:
                    return .separator

                case .multiplier:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { underlyingConstraint.multiplier },
                        range: { -CGFloat.infinity...CGFloat.infinity },
                        stepValue: { 0.1 },
                        handler: nil
                    )
                case .identifier:
                    return .textField(
                        title: property.rawValue,
                        placeholder: constraint.underlyingConstraint?.safeIdentifier ?? property.rawValue,
                        axis: .vertical,
                        value: { underlyingConstraint.safeIdentifier },
                        handler: { underlyingConstraint.identifier = $0 }
                    )
                case .priority:
                    return .floatStepper(
                        title: property.rawValue,
                        value: { underlyingConstraint.priority.rawValue },
                        range: { UILayoutPriority.fittingSizeLevel.rawValue...UILayoutPriority.required.rawValue },
                        stepValue: { 50 },
                        handler: { underlyingConstraint.priority = .init($0) }
                    )
                case .firstItem:
                    return .optionsList(
                        title: property.rawValue,
                        emptyTitle: property.rawValue,
                        axis: .vertical,
                        options: [constraint.first.displayName],
                        selectedIndex: { 0 },
                        handler: nil
                    )
                case .relation:
                    return .optionsList(
                        title: property.rawValue,
                        emptyTitle: property.rawValue,
                        options: NSLayoutConstraint.Relation.allCases.map(\.description),
                        selectedIndex: { NSLayoutConstraint.Relation.allCases.firstIndex(of: underlyingConstraint.relation) },
                        handler: nil
                    )
                case .secondItem:
                    guard let second = constraint.second else { return nil }

                    return .optionsList(
                        title: property.rawValue,
                        emptyTitle: property.rawValue,
                        axis: .vertical,
                        options: [second.displayName],
                        selectedIndex: { 0 },
                        handler: nil
                    )
                }
            }
        }
    }
}
