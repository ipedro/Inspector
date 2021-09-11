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
                    return "\(owningView.accessibilityIdentifierOrClassName).\(type(of: layoutGuide))"
                }
                return String(describing: type(of: layoutGuide))

            case let .other(object):
                return String(describing: object)
            }
        }
    }

    let rootConstraint: NSLayoutConstraint

    let rootView: UIView?

    let title: Title

    let first: Binding

    let second: Binding?

    let axis: NSLayoutConstraint.Axis

    init?(with rootConstraint: NSLayoutConstraint, inRelationTo rootView: UIView) {
        guard
            rootConstraint.isActive,
            let firstItem = Item(with: rootConstraint.firstItem),
            let firstAxis = rootConstraint.firstAttribute.axis
        else {
            return nil
        }

        let first = Binding(
            item: firstItem,
            attribute: rootConstraint.firstAttribute,
            anchor: rootConstraint.firstAnchor
        )

        let second: Binding?

        if let secondAnchor = rootConstraint.secondAnchor,
           let secondItem = Item(with: rootConstraint.secondItem)
        {
            second = Binding(
                item: secondItem,
                attribute: rootConstraint.secondAttribute,
                anchor: secondAnchor
            )
        }
        else {
            second = nil
        }

        let myBindings = Self.find(.mine, bindings: first, second, inRelationTo: rootView)

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
        self.rootConstraint = rootConstraint
        self.rootView = rootView

        if let identifier = rootConstraint.safeIdentifier {
            let multiplier = rootConstraint.multiplier != 1 ? rootConstraint.multiplier : nil
            let constant = rootConstraint.constant != 0 ? rootConstraint.constant : nil
            title = .identifier(identifier, value: multiplier?.string(appending: "x") ?? constant?.string(appending: " pt"))
            return
        }

        let theirBindings = Self.find(.theirs, bindings: first, second, inRelationTo: rootView)

        switch theirBindings.count {
        case .zero where myBindings.count > .zero && rootConstraint.multiplier != 1:
            title = .aspectRatio(multiplier: rootConstraint.multiplier)

        case .zero where myBindings.count > .zero:
            guard let firstAttributeName = first.attribute.displayName else {
                return nil
            }

            title = .constant(
                attributeName: firstAttributeName,
                relation: rootConstraint.relation,
                constant: rootConstraint.constant
            )

        case 1 where rootConstraint.multiplier != 1:
            title = .proportional(
                attribute: myBindings.first?.attribute.displayName,
                to: theirBindings.first!.item.displayName
            )

        case 1:
            title = .relative(
                from: myBindings.first?.attribute.displayName,
                to: theirBindings.first!.item.displayName
            )

        default:
            return nil
        }
    }

    static func find(_ ownership: Ownership, bindings: Binding?..., inRelationTo view: UIView?) -> [Binding] {
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

    var mine: Binding? {
        guard let rootView = rootView else { return nil }

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
        guard let rootView = rootView else { return nil }

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
        let priority = rootConstraint.priority != .required ? rootConstraint.priority : nil

        return [
            title.description,
            priority?.displayName.string(prepending: "(", appending: ")"),
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
}

extension NSLayoutConstraintInspectableViewModel {
    enum Title: CustomStringConvertible, Hashable {
        case identifier(String, value: String?)
        case aspectRatio(multiplier: CGFloat)
        case proportional(attribute: String? = nil, to: String)
        case relative(from: String? = nil, to: String)
        case constant(attributeName: String, relation: NSLayoutConstraint.Relation, constant: CGFloat)

        var description: String {
            switch self {
            case let .identifier(identifier, value):
                return [
                    identifier,
                    value?.string(prepending: "(", appending: ")"),
                ]
                .compactMap { $0 }
                .joined(separator: " ")

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
