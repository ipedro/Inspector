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
    func layerView(_ layerView: LayerViewProtocol, didSelect reference: ViewHierarchyReference, withAction action: ViewHierarchyAction)
}

class LayerView: UIImageView, LayerViewProtocol {
    weak var delegate: LayerViewDelegate?

    var shouldPresentOnTop = false

    let reference: ViewHierarchyReference

    var allowsImages = false

    var color: UIColor {
        didSet {
            guard color != oldValue else { return }

            layerBorderColor = color
        }
    }

    // MARK: - Setters

    override var image: UIImage? {
        get { allowsImages ? super.image : nil }
        set { if allowsImages { super.image = newValue } }
    }

    var layerBorderWidth: CGFloat {
        get { borderedView.layer.borderWidth }
        set { borderedView.layer.borderWidth = newValue }
    }

    var layerBackgroundColor: UIColor? {
        get { borderedView.backgroundColor }
        set { borderedView.backgroundColor = newValue }
    }

    var layerBorderColor: UIColor? {
        get {
            guard let borderColor = borderedView.layer.borderColor else { return nil }

            return UIColor(cgColor: borderColor)
        }
        set { borderedView.layer.borderColor = newValue?.cgColor }
    }

    open var sourceView: UIView { self }

    // MARK: - Components

    private lazy var borderedView = LayerViewComponent(frame: bounds).then {
        $0.layer.borderColor = color.cgColor
        $0.layer.allowsEdgeAntialiasing = true
        $0.matchLayerProperties(of: self)
    }

    @available(iOS 13.0, *)
    private lazy var menuInteraction = UIContextMenuInteraction(delegate: self)

    // MARK: - Init

    init(frame: CGRect, reference: ViewHierarchyReference, color: UIColor, borderWidth: CGFloat) {
        self.reference = reference

        self.color = color

        super.init(frame: frame)

        layerBorderWidth = borderWidth

        installView(borderedView, .autoResizingMask)

        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        matchLayerProperties(of: superview)
        borderedView.matchLayerProperties(of: superview)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if #available(iOS 13.0, *) {
            newSuperview?.addInteraction(menuInteraction)
        }

        guard newSuperview == nil else { return }

        // reset views
        reference.rootView?.isUserInteractionEnabled = reference.isUserInteractionEnabled
        if #available(iOS 13.0, *) {
            superview?.removeInteraction(menuInteraction)
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        matchLayerProperties(of: superview)
        borderedView.matchLayerProperties(of: superview)
    }
}

private extension UIView {
    func matchLayerProperties(of otherView: UIView?) {
        guard let otherView = otherView else { return }

        if #available(iOS 13.0, *) {
            layer.cornerCurve = otherView.layer.cornerCurve
        }

        layer.maskedCorners = otherView.layer.maskedCorners

        layer.cornerRadius = otherView.layer.cornerRadius
    }
}

@available(iOS 13.0, *)
extension LayerView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .contextMenuConfiguration(for: reference) { [weak self] reference, action in
            guard let self = self else { return }

            self.delegate?.layerView(self, didSelect: reference, withAction: action)
        }
    }
}
