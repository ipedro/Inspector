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

extension HighlightView {
    final class ElementNameView: LayerViewComponent {
        private(set) lazy var label = UILabel().then {
            $0.font = UIFont(name: "MuktaMahee-Regular", size: 12)
            $0.textColor = .white
            $0.textAlignment = .center
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        private(set) lazy var imageView = UIImageView().then {
            $0.tintColor = .white
            $0.clipsToBounds = true
        }

        override var tintColor: UIColor! {
            didSet {
                roundedPillView.backgroundColor = tintColor
                layer.shadowColor = tintColor.darker(amount: 0.99).cgColor
            }
        }

        private(set) lazy var roundedPillView = LayerViewComponent().then {
            $0.backgroundColor = tintColor
            $0.contentView.addArrangedSubviews(imageView, label)
            $0.contentView.spacing = 2
            $0.contentView.alignment = .center
            $0.contentView.axis = .horizontal
            $0.contentView.directionalLayoutMargins = .init(horizontal: 2, vertical: 1)
            $0.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
            $0.contentView.layer.shadowColor = UIColor.black.cgColor
            $0.contentView.layer.shadowRadius = 3
            $0.contentView.layer.shadowOpacity = 0.75
            $0.layer.cornerRadius = 6
        }

        override func setup() {
            super.setup()

            layer.shadowOffset = CGSize(width: 0, height: 1.5)
            layer.shadowRadius = 3
            layer.shadowOpacity = 0.4
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale

            installView(roundedPillView, .autoResizingMask)
        }
    }
}

final class HighlightView: LayerView, DraggableViewProtocol {
    // MARK: - Properties

    var draggableAreaLayoutGuide: UILayoutGuide { layoutMarginsGuide }

    var isDragging: Bool = false {
        didSet {
            updateColors(isDragging: isDragging)
        }
    }

    var name: String {
        didSet {
            elementNameView.label.isHidden = false
            elementNameView.label.text = name + "  "
        }
    }

    let colorScheme: ViewHierarchyColorScheme

    override var borderColor: UIColor? {
        didSet {
            guard borderColor != oldValue else {
                return
            }

            updateColors()
        }
    }

    var labelWidthConstraint: NSLayoutConstraint? {
        didSet {
            guard let oldConstraint = oldValue else {
                return
            }

            oldConstraint.isActive = false
        }
    }

    var verticalAlignmentOffset: CGFloat {
        get {
            verticalAlignmentConstraint.constant
        }
        set {
            verticalAlignmentConstraint.constant = newValue
        }
    }

    var draggableView: UIView { elementNameView }

    override var sourceView: UIView { draggableView }

    private lazy var verticalAlignmentConstraint = elementNameView.centerYAnchor.constraint(equalTo: centerYAnchor)

    // MARK: - Components

    private lazy var elementNameView = ElementNameView()

    private lazy var layoutMarginsShadeLayer = CAShapeLayer().then {
        $0.fillRule = .evenOdd
        layoutMarginsGuideView.layer.addSublayer($0)
    }

    private lazy var layoutMarginsGuideView = UIView().then {
        installView($0, .spacing(top: .zero, leading: .zero, bottom: .zero))
    }

    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(move(with:)))

    private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLayerView))

    // MARK: - Init

    init(
        frame: CGRect,
        name: String,
        colorScheme: ViewHierarchyColorScheme,
        element: ViewHierarchyElement,
        border borderWidth: CGFloat = Inspector.configuration.appearance.highlightLayerBorderWidth
    ) {
        self.colorScheme = colorScheme
        self.name = name

        super.init(
            frame: frame,
            element: element,
            color: .systemGray,
            border: borderWidth
        )

        preservesSuperviewLayoutMargins = true

        isUserInteractionEnabled = true

        shouldPresentOnTop = true

        draggableView.addGestureRecognizer(tapGestureRecognizer)
        draggableView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    private func move(with gesture: UIPanGestureRecognizer) {
        dragView(with: gesture)
    }

    @objc
    private func tapLayerView() {
        delegate?.layerView(self, didSelect: element, withAction: .inspect(preferredPanel: .none))
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        sourceView.frame.insetBy(dx: -20, dy: -20).contains(point)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateColors(isDragging: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updateColors()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        updateColors()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let superview = superview else {
            elementNameView.removeFromSuperview()
            return
        }

        setupViews(with: superview)
    }

    private var latestElementSnapshot: UUID?

    override func layoutSubviews() {
        super.layoutSubviews()

        guard latestElementSnapshot != element.latestSnapshot.identifier else {
            return
        }

        elementNameView.label.isSafelyHidden = false

        updateViews()

        latestElementSnapshot = element.latestSnapshot.identifier

        let size = elementNameView.systemLayoutSizeFitting(frame.size)

        elementNameView.label.isHidden = size.width > frame.width * 1.6
    }

    func updateViews() {
        updateElementName()

        guard let superview = superview else { return }

        let color = colorScheme.value(for: superview)

        layoutMarginsShadeLayer.fillColor = color.cgColor

        borderColor = color

        maskLayoutMarginsGuideView(with: superview)
    }

    private func maskLayoutMarginsGuideView(with view: UIView) {
        let path: UIBezierPath = {
            let pathBigRect = UIBezierPath(
                roundedRect: view.bounds,
                byRoundingCorners: view.layer.maskedCorners.rectCorner,
                cornerRadii: CGSize(view.layer.cornerRadius)
            )

            let pathSmallRect = UIBezierPath(rect: view.layoutMarginsGuide.layoutFrame)

            pathBigRect.append(pathSmallRect)

            pathBigRect.usesEvenOddFillRule = true

            return pathBigRect
        }()

        layoutMarginsShadeLayer.path = path.cgPath

        switch colorStyle {
        case .light:
            layoutMarginsGuideView.alpha = 0.14
        case .dark:
            layoutMarginsGuideView.alpha = 0.1
        }
    }

    func updateElementName() {
        name = element.viewController?.classNameWithoutQualifiers ?? element.elementName

        if let image = element.iconImage?.resized(CGSize(16)) {
            if image != elementNameView.imageView.image {
                elementNameView.imageView.image = image
                elementNameView.imageView.isSafelyHidden = false
            }
        }
        else {
            elementNameView.imageView.image = nil
            elementNameView.imageView.isSafelyHidden = true
        }
    }
}

extension CACornerMask {
    var rectCorner: UIRectCorner {
        var corner = UIRectCorner()
        if contains(.layerMaxXMaxYCorner) {
            corner.insert(.bottomRight)
        }
        if contains(.layerMaxXMinYCorner) {
            corner.insert(.topRight)
        }
        if contains(.layerMinXMaxYCorner) {
            corner.insert(.bottomLeft)
        }
        if contains(.layerMinXMinYCorner) {
            corner.insert(.topLeft)
        }
        return corner
    }
}

private extension HighlightView {
    func setupViews(with hostView: UIView) {
        updateColors()

        installView(elementNameView, .centerX)

        verticalAlignmentConstraint.isActive = true

        updateViews()

        isSafelyHidden = false

        hostView.isUserInteractionEnabled = true
    }

    func updateColors(isDragging: Bool = false) {
        switch isDragging {
        case true:
            elementNameView.tintColor = borderColor
            backgroundColor = borderColor?.withAlphaComponent(colorStyle.disabledAlpha)
            borderWidth = 3 / UIScreen.main.scale

        case false:
            elementNameView.tintColor = borderColor?.withAlphaComponent(0.85)
            backgroundColor = borderColor?.withAlphaComponent(colorStyle.disabledAlpha * 0.1)
            borderWidth = 1 / UIScreen.main.scale
        }
    }
}
