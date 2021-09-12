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

private extension NSLayoutConstraint.Relation {
    var label: String {
        switch self {
        case .lessThanOrEqual:
            return "Less Than Or Equal"
        case .equal:
            return "Equals"
        case .greaterThanOrEqual:
            return "Greater Than Or Equal"
        @unknown default:
            return "Unknown"
        }
    }
}

private extension NSLayoutConstraint.Attribute {
    var axis: NSLayoutConstraint.Axis? {
        switch self {
        case .left,
             .leftMargin,
             .right,
             .rightMargin,
             .leading,
             .leadingMargin,
             .trailing,
             .trailingMargin,
             .centerX,
             .centerXWithinMargins,
             .width:
            return .horizontal
        case .top,
             .topMargin,
             .bottom,
             .bottomMargin,
             .centerY,
             .centerYWithinMargins,
             .lastBaseline,
             .firstBaseline,
             .height:
            return .vertical
        case .notAnAttribute:
            return nil
        @unknown default:
            return nil
        }
    }

    var displayName: String? {
        switch self {
        case .left,
             .leftMargin:
            return "Left Space"
        case .right,
             .rightMargin:
            return "Right Space"
        case .top,
             .topMargin:
            return "Top Space"
        case .bottom,
             .bottomMargin:
            return "Bottom Space"
        case .leading,
             .leadingMargin:
            return "Leading Space"
        case .trailing,
             .trailingMargin:
            return "Trailing Space"
        case .width:
            return "Width"
        case .height:
            return "Height"
        case .centerX,
             .centerXWithinMargins:
            return "Align Center X"
        case .centerY,
             .centerYWithinMargins:
            return "Align Center Y"
        case .lastBaseline:
            return "Last Baseline"
        case .firstBaseline:
            return "First Baseline"
        case .notAnAttribute:
            return nil
        @unknown default:
            return nil
        }
    }

    var isRelativeToMargin: Bool {
        switch self {
        case .leftMargin,
             .rightMargin,
             .topMargin,
             .bottomMargin,
             .leadingMargin,
             .trailingMargin,
             .centerXWithinMargins,
             .centerYWithinMargins:
            return true
        default:
            return false
        }
    }
}

private extension NSLayoutConstraint {
    var safeIdentifier: String? {
        if identifier != nil {
            return identifier!
        }
        else {
            return nil
        }
    }
}

private extension UILayoutPriority {
    var displayName: String {
        switch self {
        case .defaultHigh:
            return "High"
        case .defaultLow:
            return "Low"
        case .fittingSizeLevel:
            return "Fitting Size"
        case .required:
            return "Required"
        case .dragThatCanResizeScene:
            return "Drag That Can Resize Scene"
        case .sceneSizeStayPut:
            return "Scene Size Stay Put"
        case .dragThatCannotResizeScene:
            return "Drag That Can't Resize Scene"
        default:
            return rawValue.string()
        }
    }
}

private extension UIView {
    var accessibilityIdentifierOrClassName: String {
        accessibilityIdentifier ?? className
    }
}

private extension BinaryFloatingPoint {
    func string(prepending: String? = nil, appending: String? = nil, separator: String = "") -> String {
        guard let formattedNumber = NSLayoutConstraintInspectableViewModel.numberFormatter.string(from: CGFloat(self)) else {
            return String()
        }

        return formattedNumber.string(prepending: prepending, appending: appending, separator: separator)
    }
}

private extension String {
    func string(prepending: String? = nil, appending: String? = nil, separator: String = "") -> String {
        [prepending, self, appending].compactMap { $0 }.joined(separator: separator)
    }
}

struct NSLayoutConstraintInspectableViewModel: Hashable {
    static let numberFormatter = NumberFormatter().then {
        $0.maximumFractionDigits = 2
        $0.numberStyle = .decimal
    }

    let constraint: NSLayoutConstraint

    let view: UIView?

    let type: `Type`

    let first: Binding

    let second: Binding?

    let axis: NSLayoutConstraint.Axis

    init?(with constraint: NSLayoutConstraint, in view: UIView) {
        guard
            let firstItem = Item(with: constraint.firstItem),
            let firstAxis = constraint.firstAttribute.axis
        else {
            return nil
        }

        let first = Binding(
            item: firstItem,
            attribute: constraint.firstAttribute,
            anchor: constraint.firstAnchor
        )

        let second: Binding?

        if let secondAnchor = constraint.secondAnchor,
           let secondItem = Item(with: constraint.secondItem)
        {
            second = Binding(
                item: secondItem,
                attribute: constraint.secondAttribute,
                anchor: secondAnchor
            )
        }
        else {
            second = nil
        }

        let myBindings = Self.find(.mine, bindings: first, second, inRelationTo: view)

        guard
            first.item.targetView as? InternalViewProtocol == nil,
            second?.item.targetView as? InternalViewProtocol == nil,
            myBindings.isEmpty == false
        else {
            return nil
        }

        axis = firstAxis
        self.first = first
        self.second = second
        self.constraint = constraint
        self.view = view

        if let identifier = constraint.safeIdentifier {
            type = .identifier(identifier)
            return
        }

        let theirBindings = Self.find(.theirs, bindings: first, second, inRelationTo: view)

        switch theirBindings.count {
        case .zero where myBindings.count > .zero && constraint.multiplier != 1:
            type = .aspectRatio(multiplier: constraint.multiplier)

        case .zero where myBindings.isEmpty == false:
            guard let firstAttributeName = first.attribute.displayName else { return nil }

            type = .constant(
                attributeName: firstAttributeName,
                relation: constraint.relation,
                constant: constraint.constant
            )

        case 1 where constraint.multiplier != 1:
            guard let theirFirstBinding = theirBindings.first else { return nil }

            type = .proportional(
                attribute: myBindings.first?.attribute.displayName,
                to: theirFirstBinding.item.displayName
            )

        case 1:
            guard let theirFirstBinding = theirBindings.first else { return nil }

            type = .relative(
                from: myBindings.first?.attribute.displayName,
                to: theirFirstBinding.item.displayName
            )

        default:
            return nil
        }
    }

    private static func find(_ ownership: Ownership, bindings: Binding?..., inRelationTo view: UIView?) -> [Binding] {
        bindings.compactMap { binding in
            guard
                let view = view,
                let binding = binding,
                binding.ownership(to: view) == ownership
            else {
                return nil
            }

            return binding
        }
    }
}

// MARK: - Computed Properties

extension NSLayoutConstraintInspectableViewModel {
    var mine: Binding? {
        guard let rootView = view else { return nil }

        if case .mine = first.ownership(to: rootView) {
            return first
        }
        else if case .mine = second?.ownership(to: rootView) {
            return second
        }
        else {
            assertionFailure("should this happen?")
            return nil
        }
    }

    var theirs: Binding? {
        guard let rootView = view else { return nil }

        if case .theirs = first.ownership(to: rootView) {
            return first
        }
        else if case .theirs = second?.ownership(to: rootView) {
            return second
        }
        else {
            return nil
        }
    }

    var displayName: String? {
        let priority = constraint.priority != .required ? constraint.priority : nil

        return [
            type.description,
            priority?.displayName.string(prepending: "(", appending: ")")
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }

    enum Ownership {
        case mine, theirs
    }

    struct Binding: Hashable {
        var item: Item
        var attribute: NSLayoutConstraint.Attribute
        var anchor: NSLayoutAnchor<AnyObject>

        var displayName: String {
            guard let attributeName = attribute.displayName else {
                return item.displayName
            }
            return "\(item.displayName).\(attributeName)"
        }

        func ownership(to view: UIView) -> Ownership {
            ObjectIdentifier(item.target) == ObjectIdentifier(view) ? .mine : .theirs
        }
    }

    enum Item: Hashable {
        case view(UIView)
        case layoutGuide(UILayoutGuide)
        case other(NSObject)

        var targetView: UIView? {
            switch self {
            case let .layoutGuide(layoutGuide):
                return layoutGuide.owningView

            case let .view(view):
                return view

            case .other:
                return nil
            }
        }

        var target: NSObject {
            switch self {
            case let .layoutGuide(layoutGuide):
                return layoutGuide.owningView ?? layoutGuide

            case let .view(view):
                return view

            case let .other(object):
                return object
            }
        }

        init?(with object: AnyObject?) {
            switch object {
            case let view as UIView:
                self = .view(view)

            case let layoutGuide as UILayoutGuide:
                self = .layoutGuide(layoutGuide)

            case let object as NSObject:
                self = .other(object)

            default:
                return nil
            }
        }

        var displayName: String {
            switch self {
            case let .view(view):
                return view.accessibilityIdentifierOrClassName

            case let .layoutGuide(layoutGuide):
                if let owningView = layoutGuide.owningView {
                    return "\(owningView.accessibilityIdentifierOrClassName).\(layoutGuide.classForCoder)"
                }
                return String(describing: layoutGuide.classForCoder)

            case let .other(object):
                return String(describing: object)
            }
        }
    }

    enum `Type`: CustomStringConvertible, Hashable {
        case identifier(String)
        case aspectRatio(multiplier: CGFloat)
        case proportional(attribute: String? = nil, to: String)
        case relative(from: String? = nil, to: String)
        case constant(attributeName: String, relation: NSLayoutConstraint.Relation, constant: CGFloat)

        var description: String {
            switch self {
            case let .identifier(identifier):
                return identifier

            case let .aspectRatio(multiplier: multiplier):
                return "Aspect Ratio \(multiplier)"

            case let .proportional(attribute: attributeString?, to: toString):
                return "Proportional \(attributeString) to: \(toString)"

            case let .proportional(attribute: .none, to: toString):
                return "Proportional to: \(toString)"

            case let .relative(from: fromString?, to: toString):
                return "\(fromString) to: \(toString)"

            case let .relative(from: .none, to: toString):
                return "To: \(toString)"

            case let .constant(attributeName: attribute, relation: relation, constant: constant):
                return "\(attribute) \(relation.label): \(constant.string())"
            }
        }
    }
}

extension NSLayoutConstraintInspectableViewModel: InspectorAutoLayoutViewModelProtocol {
    private enum Property: String, Swift.CaseIterable {
        case firstItem = "First Item"
        case relation = "Relation"
        case secondItem = "Second Item"
        case spacer1
        case constant = "Constant"
        case priority = "Priority"
        case multiplier = "Multiplier"
        case spacer2
        case identifier = "Identifier"
        case spacer3
        case isActive = "Installed"
    }

    var title: String { type.description }

    var properties: [InspectorElementViewModelProperty] {
        Property.allCases.compactMap { property in
            switch property {
            case .constant:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { constraint.constant },
                    range: { -CGFloat.infinity...CGFloat.infinity },
                    stepValue: { 1 },
                    handler: { constraint.constant = $0 }
                )
            case .spacer1,
                 .spacer2,
                 .spacer3:
                return .separator(title: "")

            case .multiplier:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { constraint.multiplier },
                    range: { -CGFloat.infinity...CGFloat.infinity },
                    stepValue: { 0.1 },
                    handler: nil
                )

            case .identifier:
                return .textField(
                    title: property.rawValue,
                    placeholder: constraint.safeIdentifier ?? property.rawValue,
                    value: { constraint.safeIdentifier },
                    handler: { constraint.identifier = $0 }
                )

            case .isActive:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { constraint.isActive },
                    handler: { constraint.isActive = $0 }
                )

            case .priority:
                return .floatStepper(
                    title: property.rawValue,
                    value: { constraint.priority.rawValue },
                    range: { UILayoutPriority.fittingSizeLevel.rawValue...UILayoutPriority.required.rawValue },
                    stepValue: { 50 },
                    handler: { constraint.priority = .init($0) }
                )

            default:
                return nil
            }
        }
    }
}
