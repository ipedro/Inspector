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

enum ViewInstallationPosition {
    case inFront, behind
}

enum ViewBinding {
    case centerX

    case centerXY

    case centerY

    case margins(
        top: CGFloat? = nil,
        leading: CGFloat? = nil,
        bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    )

    case autoResizingMask(UIView.AutoresizingMask)

    static let autoResizingMask = ViewBinding.autoResizingMask([.flexibleWidth, .flexibleHeight])

    static func margins(_ margins: CGFloat) -> ViewBinding {
        .margins(top: margins, leading: margins, bottom: margins, trailing: margins)
    }

    static func margins(horizontal: CGFloat, vertical: CGFloat) -> ViewBinding {
        .margins(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    static func insets(_ insets: UIEdgeInsets) -> ViewBinding {
        .margins(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
    }

    static func insets(_ insets: NSDirectionalEdgeInsets) -> ViewBinding {
        .margins(top: insets.top, leading: insets.leading, bottom: insets.bottom, trailing: insets.trailing)
    }
}

extension UIView {
    var allSubviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSubviews }
    }

    var originalSubviews: [UIView] {
        subviews.filter { $0 is LayerViewProtocol == false }
    }

    func installView(
        _ view: UIView,
        _ viewBinding: ViewBinding = .margins(.zero),
        position: ViewInstallationPosition = .inFront,
        priority: UILayoutPriority = .defaultHigh
    ) {
        switch position {
        case .inFront:
            addSubview(view)

        case .behind:
            insertSubview(view, at: .zero)
        }

        switch viewBinding {
        case let .autoResizingMask(mask):
            view.autoresizingMask = mask

        case .centerX,
             .centerY,
             .centerXY,
             .margins:
            let constraints = viewBinding.constraints(for: view, inside: self)

            view.translatesAutoresizingMaskIntoConstraints = false

            constraints.forEach {
                $0.priority = priority
                $0.isActive = true
            }
        }
    }

    /**
     A Boolean value that determines whether the view is hidden and works around a [UIStackView bug](http://www.openradar.me/25087688) affecting iOS 9.2+.
     */
    var isSafelyHidden: Bool {
        get {
            isHidden
        }
        set {
            isHidden = false
            isHidden = newValue
        }
    }
}

private extension ViewBinding {
    func constraints(for view: UIView, inside superview: UIView) -> [NSLayoutConstraint] {
        switch self {
        case .centerX:
            return [
                view.centerXAnchor.constraint(equalTo: superview.centerXAnchor)
            ]

        case .centerY:
            return [
                view.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ]

        case .centerXY:
            return [
                view.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ]

        case .autoResizingMask:
            return []

        case let .margins(top, leading, bottom, trailing):
            var constraints = [NSLayoutConstraint]()

            if let top = top {
                constraints.append(view.topAnchor.constraint(equalTo: superview.topAnchor, constant: top))
            }
            if let leading = leading {
                constraints.append(view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading))
            }
            if let bottom = bottom {
                constraints.append(view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom))
            }
            if let trailing = trailing {
                constraints.append(view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -trailing))
            }

            return constraints
        }
    }
}
