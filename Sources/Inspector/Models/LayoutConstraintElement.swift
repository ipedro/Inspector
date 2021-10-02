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

final class LayoutConstraintElement: Hashable {
    static func == (lhs: LayoutConstraintElement, rhs: LayoutConstraintElement) -> Bool {
        lhs.underlyingConstraint == rhs.underlyingConstraint
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(underlyingConstraint)
    }

    weak var underlyingConstraint: NSLayoutConstraint?

    weak var view: UIView?

    let type: `Type`

    let first: Binding

    let second: Binding?

    let axis: Axis

    init?(with constraint: NSLayoutConstraint, in view: UIView) {
        guard
            let firstItem = Item(with: constraint.firstItem),
            let firstAxis = Axis(constraint.firstAttribute.axis)
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
            first.item.targetView as? NonInspectableView == nil,
            second?.item.targetView as? NonInspectableView == nil,
            myBindings.isEmpty == false
        else {
            return nil
        }

        axis = firstAxis
        self.first = first
        self.second = second
        self.underlyingConstraint = constraint
        self.view = view

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

extension LayoutConstraintElement {
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
        let priority = underlyingConstraint?.priority != .required ? underlyingConstraint?.priority : nil

        return [
            type.description,
            priority?.description.string(prepending: "(", appending: ")")
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }

    enum Ownership {
        case mine, theirs
    }
}

// MARK: - Binding

extension LayoutConstraintElement {
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
}

// MARK: - Axis

extension LayoutConstraintElement {
    enum Axis: Int, Swift.CaseIterable, Hashable {
        case horizontal = 0
        case vertical = 1

        init?(_ axis: NSLayoutConstraint.Axis?) {
            switch axis {
            case .horizontal:
                self = .horizontal
            case .vertical:
                self = .vertical
            default:
                return nil
            }
        }
    }
}

// MARK: - Item

extension LayoutConstraintElement {
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
                return view.elementName

            case let .layoutGuide(layoutGuide):
                if let owningView = layoutGuide.owningView {
                    return String(describing: layoutGuide.classForCoder).replacingOccurrences(of: "UILayoutGuide", with: "\(owningView.elementName) Margins")
                }
                return String(describing: layoutGuide.classForCoder)

            case let .other(object):
                return String(describing: object)
            }
        }
    }
}

// MARK: - Type

extension LayoutConstraintElement {
    enum `Type`: CustomStringConvertible, Hashable {
        case aspectRatio(multiplier: CGFloat)
        case proportional(attribute: String? = nil, to: String)
        case relative(from: String? = nil, to: String)
        case constant(attributeName: String, relation: NSLayoutConstraint.Relation, constant: CGFloat)

        var description: String {
            switch self {
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
                return "\(attribute) \(relation.description): \(constant.toString())"
            }
        }
    }
}
