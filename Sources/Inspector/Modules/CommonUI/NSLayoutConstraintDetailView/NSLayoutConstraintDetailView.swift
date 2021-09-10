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

fileprivate extension NSLayoutConstraint.Relation {
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

fileprivate extension NSLayoutConstraint.Attribute {
    var label: String {
        switch self {
        case .left,
             .leftMargin:
            return "Left"
        case .right,
             .rightMargin:
            return "Right"
        case .top,
             .topMargin:
            return "Top"
        case .bottom,
             .bottomMargin:
            return "Bottom"
        case .leading,
             .leadingMargin:
            return "Leading"
        case .trailing,
             .trailingMargin:
            return "Trailing"
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
            return "Not An Attribute"
        @unknown default:
            return "Unknown"
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

enum NSLayoutConstraintDescription {
    case aspectRatio(multiplier: CGFloat)

    case proportional(attribute: NSLayoutConstraint.Attribute, to: AnyObject)

    case relative(attribute: NSLayoutConstraint.Attribute, to: AnyObject)

    case constant(attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat)

    case unknown(NSLayoutConstraint)

    var rawValue: String {
        switch self {

        case let .unknown(constraint):
            return "Unknown: \(constraint.debugDescription)"

        case .aspectRatio(multiplier: let multiplier):
            return "Aspect Ratio \(multiplier)"

        case let .proportional(attribute: attribute, to: otherView as UIView):
            return "Proportional \(attribute.label) to: \(otherView.displayName)"

        case let .proportional(attribute: attribute, to: other):
            return "Proportional \(attribute.label) to: \(String(describing: type(of: other)))"

        case let .relative(attribute, to: otherView as UIView):
            return "\(attribute.label) to: \(otherView.displayName)"

        case let .relative(attribute: attribute, to: other):
            return "Proportional \(attribute.label) to: \(String(describing: type(of: other)))"

        case let .constant(attribute: attribute, relation: relation, constant: constant):
            return "\(attribute.label) \(relation.label): \(constant)"
        }
    }

    init?(with constraint: NSLayoutConstraint, inRelationTo view: UIView) {
        guard
            !(constraint.firstItem is InternalViewProtocol),
            !(constraint.secondItem is InternalViewProtocol)
        else {
            return nil
        }

        switch (constraint.firstItem, constraint.secondItem) {
        case let (item?, .none) where constraint.multiplier > 0 && item === view,
             let (.none, item?) where constraint.multiplier > 0 && item === view:
            self = .aspectRatio(multiplier: constraint.multiplier)

        case let (item?, .none) where item === view,
             let (.none, item?) where item === view:
            self = .constant(
                attribute: constraint.firstAttribute,
                relation: constraint.relation,
                constant: constraint.constant
            )

        case let (item?, other?) where item === view && constraint.multiplier > 0:
            self = .proportional(attribute: constraint.firstAttribute, to: other)

        case let (other?, item?) where item === view && constraint.multiplier > 0:
            self = .proportional(attribute: constraint.secondAttribute, to: other)

        case let (item?, other?) where item === view:
            self = .relative(attribute: constraint.firstAttribute, to: other)

        case let (other?, item?) where item === view:
            self = .relative(attribute: constraint.firstAttribute, to: other)

        default:
            return nil
        }
    }
}


//struct NSLayoutConstraintViewModel {
//
//    private let constraint: NSLayoutConstraint
//
//    init(constraint: NSLayoutConstraint) {
//        self.constraint = constraint
//    }
//
//    var isActive: Bool { constraint.isActive }
//
//    var description: String { NSLayoutConstraintDescription(with: constraint).rawValue }
//}

//final class NSLayoutConstraintDetailView: BaseView {
//    private(set) var viewModel: NSLayoutConstraintViewModel
//
//    init(with constraint: NSLayoutConstraint, frame: CGRect = .zero) {
//        self.viewModel = NSLayoutConstraintViewModel(constraint: constraint)
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func setup() {
//        super.setup()
//    }
//}
