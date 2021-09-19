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

struct NSLayoutConstraintInspectableViewModel: InspectorElementViewModelProtocol, Hashable {
    typealias Axis = NSLayoutConstraintReference.Axis

    private enum Property: String, Swift.CaseIterable {
        case isActive = "Installed"
        case spacer0
        case firstItem = "First Item"
        case relation = "Relation"
        case secondItem = "Second Item"
        case spacer1
        case constant = "Constant"
        case priority = "Priority"
        case multiplier = "Multiplier"
        case spacer2
        case identifier = "Identifier"
    }

    init?(with constraint: NSLayoutConstraint, in view: UIView) {
        guard let constraintReference = NSLayoutConstraintReference(with: constraint, in: view) else { return nil }
        self.constraintReference = constraintReference
    }

    let constraintReference: NSLayoutConstraintReference

    var axis: Axis { constraintReference.axis }

    var title: String { constraintReference.type.description }

    var subtitle: String? { constraintReference.constraint.safeIdentifier }

    var properties: [InspectorElementViewModelProperty] {
        Property.allCases.compactMap { property in
            switch property {
            case .constant:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { self.constraintReference.constraint.constant },
                    range: { -CGFloat.infinity...CGFloat.infinity },
                    stepValue: { 1 },
                    handler: { self.constraintReference.constraint.constant = $0 }
                )
            case .spacer0,
                 .spacer1,
                 .spacer2:
                return .separator

            case .multiplier:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { self.constraintReference.constraint.multiplier },
                    range: { -CGFloat.infinity...CGFloat.infinity },
                    stepValue: { 0.1 },
                    handler: nil
                )

            case .identifier:
                return .textField(
                    title: property.rawValue,
                    placeholder: constraintReference.constraint.safeIdentifier ?? property.rawValue,
                    axis: .vertical,
                    value: { self.constraintReference.constraint.safeIdentifier },
                    handler: { self.constraintReference.constraint.identifier = $0 }
                )

            case .isActive:
                return .switch(
                    title: property.rawValue,
                    isOn: { self.constraintReference.constraint.isActive },
                    handler: { self.constraintReference.constraint.isActive = $0 }
                )

            case .priority:
                return .floatStepper(
                    title: property.rawValue,
                    value: { self.constraintReference.constraint.priority.rawValue },
                    range: { UILayoutPriority.fittingSizeLevel.rawValue...UILayoutPriority.required.rawValue },
                    stepValue: { 50 },
                    handler: { self.constraintReference.constraint.priority = .init($0) }
                )

            case .firstItem:
                return .optionsList(
                    title: property.rawValue,
                    emptyTitle: property.rawValue,
                    axis: .vertical,
                    options: [constraintReference.first.displayName],
                    selectedIndex: { 0 },
                    handler: nil
                )
            case .relation:
                return .optionsList(
                    title: property.rawValue,
                    emptyTitle: property.rawValue,
                    options: NSLayoutConstraint.Relation.allCases.map(\.description),
                    selectedIndex: { NSLayoutConstraint.Relation.allCases.firstIndex(of: self.constraintReference.constraint.relation) },
                    handler: nil
                )

            case .secondItem:
                guard let second = constraintReference.second else { return nil }

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
