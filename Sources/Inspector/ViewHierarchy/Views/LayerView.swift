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

protocol LayerViewDelegate: AnyObject {
    func layerView(_ layerView: LayerViewProtocol,
                   didSelect element: ViewHierarchyElementReference,
                   withAction action: ViewHierarchyElementAction)
}

class LayerView: UIImageView, LayerViewProtocol {
    weak var delegate: LayerViewDelegate?

    var shouldPresentOnTop = false

    var element: ViewHierarchyElementReference

    var allowsImages = false

    private(set) lazy var contentView = UIStackView.vertical().then {
        installView($0, priority: .required)
    }

    // MARK: - Setters

    override var image: UIImage? {
        get { allowsImages ? super.image : nil }
        set { if allowsImages { super.image = newValue } }
    }

    var borderWidth: CGFloat {
        didSet {
            updateBorder()
        }
    }

    var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    open var sourceView: UIView { self }

    private lazy var menuInteraction = UIContextMenuInteraction(delegate: self)

    // MARK: - Init

    init(frame: CGRect,
         element: ViewHierarchyElementReference,
         color borderColor: UIColor,
         border borderWidth: CGFloat)
    {
        self.element = element
        self.borderColor = borderColor
        self.borderWidth = borderWidth

        super.init(frame: frame)

        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    private func updateBorder() {
        contentView.layer.borderColor = borderColor?.cgColor
        contentView.layer.borderWidth = borderWidth
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        if let superview = superview {
            matchCornerRadius(of: superview)
        }

        updateBorder()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        superview?.removeInteraction(menuInteraction)
        newSuperview?.addInteraction(menuInteraction)

        // reset views
        guard newSuperview == nil else { return }

        guard let viewElement = element as? ViewHierarchyElement else {
            return
        }

        viewElement.underlyingView?.isUserInteractionEnabled = viewElement.isUnderlyingViewUserInteractionEnabled
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let superview = superview else { return }
        contentView.matchCornerRadius(of: superview)
        setContentHuggingPriority(
            superview.contentHuggingPriority(for: .vertical),
            for: .vertical
        )
        setContentHuggingPriority(
            superview.contentHuggingPriority(for: .horizontal),
            for: .horizontal
        )
        setContentCompressionResistancePriority(
            superview.contentCompressionResistancePriority(for: .vertical),
            for: .vertical
        )
        setContentCompressionResistancePriority(
            superview.contentCompressionResistancePriority(for: .horizontal),
            for: .horizontal
        )
    }
}

extension UIView {
    func matchCornerRadius(of otherView: UIView) {
        layer.cornerCurve = otherView.layer.cornerCurve
        layer.maskedCorners = otherView.layer.maskedCorners
        layer.cornerRadius = otherView.layer.cornerRadius
    }
}

extension LayerView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?
    {
        .contextMenuConfiguration(with: element) { [weak self] element, action in
            guard let self = self else { return }

            self.delegate?.layerView(self, didSelect: element, withAction: action)
        }
    }
}
