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

final class WireframeView: LayerView {
    private lazy var leadingAnchorConstraint = layoutGuideView.leadingAnchor.constraint(equalTo: leadingAnchor).then { $0.isActive = true }

    private lazy var topAnchorConstraint = layoutGuideView.topAnchor.constraint(equalTo: topAnchor).then { $0.isActive = true }

    private lazy var bottomAnchorConstraint = layoutGuideView.bottomAnchor.constraint(equalTo: bottomAnchor).then { $0.isActive = true }

    private lazy var trailingAnchorConstraint = layoutGuideView.trailingAnchor.constraint(equalTo: trailingAnchor).then { $0.isActive = true }

    override init(
        frame: CGRect,
        element: ViewHierarchyElementReference,
        color borderColor: UIColor = Inspector.sharedInstance.configuration.colorStyle.wireframeLayerColor,
        border borderWidth: CGFloat = Inspector.sharedInstance.appearance.wireframeLayerBorderWidth
    ) {
        super.init(frame: frame, element: element, color: borderColor, border: borderWidth)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var layoutGuideView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderColor = borderColor?.cgColor
        $0.layer.borderWidth = borderWidth
        $0.alpha = 1 / 4
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard superview != nil else {
            layoutGuideView.removeFromSuperview()
            return
        }

        installView(layoutGuideView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let superview = superview else {
            layoutGuideView.removeFromSuperview()
            return
        }

        leadingAnchorConstraint.constant = superview.layoutMarginsGuide.layoutFrame.minX
        topAnchorConstraint.constant = superview.layoutMarginsGuide.layoutFrame.minY
        bottomAnchorConstraint.constant = superview.layoutMarginsGuide.layoutFrame.maxY - superview.bounds.maxY
        trailingAnchorConstraint.constant = superview.layoutMarginsGuide.layoutFrame.maxX - superview.bounds.maxX
    }
}
