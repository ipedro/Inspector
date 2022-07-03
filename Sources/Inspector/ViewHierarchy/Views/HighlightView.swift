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

extension HighlightView: ElementNameViewDisplayerProtocol {
    var elementFrame: CGRect {
        superview?.frame ?? frame
    }
}

extension HighlightView: DraggableViewProtocol {
    var draggableAreaAdjustedContentInset: UIEdgeInsets {
        (superview as? UIScrollView)?.adjustedContentInset ?? .zero
    }

    var draggableViewCenterOffset: CGPoint { CGPoint(x: .zero, y: -30) }

    var draggableAreaLayoutGuide: UILayoutGuide { layoutMarginsGuide }

    var draggableView: UIView { elementNameView }
}

final class HighlightView: LayerView {
    var displayMode: ElementNameView.DisplayMode {
        get {
            elementNameView.displayMode
        }
        set {
            elementNameView.displayMode = newValue
            reloadData()
        }
    }

    // MARK: - Properties

    var isDragging: Bool = false {
        didSet {
            guard isDragging != oldValue else { return }

            animate(withDuration: .veryLong) {
                switch self.isDragging {
                case true:
                    self.elementNameView.layer.shadowOpacity = 2 / 3
                    self.elementNameView.layer.shadowRadius = 15
                    self.elementNameView.layer.shadowOffset = .init(
                        width: self.draggableViewCenterOffset.x,
                        height: -self.draggableViewCenterOffset.y
                    )
                    self.elementNameView.transform = self.initialTransformation
                        .scaledBy(x: 1.5, y: 1.5)
                        .translatedBy(
                            x: self.draggableViewCenterOffset.x,
                            y: self.draggableViewCenterOffset.y
                        )
                case false:
                    self.elementNameView.resetShadow()
                    self.elementNameView.transform = .identity
                }

                self.updateViews()
            }
        }
    }

    var name: String {
        didSet {
            elementNameView.label.isHidden = false
            elementNameView.label.text = name
        }
    }

    let colorScheme: ViewHierarchyColorScheme

    override var borderColor: UIColor? {
        didSet {
            guard borderColor != oldValue else {
                return
            }

            updateViews()
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

    override var sourceView: UIView { draggableView }

    private lazy var verticalAlignmentConstraint = elementNameView.centerYAnchor.constraint(equalTo: centerYAnchor)

    // MARK: - Components

    private lazy var elementNameView = ElementNameView()

//    private lazy var layoutMarginsShadeLayer = CAShapeLayer().then {
//        $0.fillRule = .evenOdd
//        layoutMarginsGuideView.layer.addSublayer($0)
//    }
//
//    private lazy var layoutMarginsGuideView = UIView().then {
//        installView($0, .spacing(top: .zero, leading: .zero, bottom: .zero))
//    }

    private lazy var panGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(move(with:))
    )

    private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(tapLayerView)
    )

    // MARK: - Init

    init(
        frame: CGRect,
        name: String,
        colorScheme: ViewHierarchyColorScheme,
        element: ViewHierarchyElementReference,
        border borderWidth: CGFloat = Inspector.sharedInstance.appearance.highlightLayerBorderWidth
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
        delegate?.layerView(
            self,
            didSelect: element,
            withAction: .inspect(preferredPanel: .default)
        )
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        sourceView.frame.insetBy(dx: -20, dy: -20).contains(point)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        updateViews(isHighlighted: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        isDragging = false
        updateViews()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        isDragging = false
        updateViews()
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

    func updateViewsIfNeeded() {
        if
            let latestElementSnapshot = latestElementSnapshot,
            element.hasChanges(inRelationTo: latestElementSnapshot) == false
        {
            return
        }

        latestElementSnapshot = element.latestSnapshotIdentifier

        updateElementName()
        updateBorderColor()
    }

    private func updateBorderColor() {
        guard let superview = superview else { return }

        let isDarkMode = colorStyle == .dark

        let color = colorScheme
            .value(for: superview)
            .darker(amount: isDarkMode ? 0.3 : 0)

        borderColor = color
    }

    enum Transition {
        typealias Settings = (transform: CGAffineTransform, alpha: CGFloat)
        case appear, dismiss
    }

    private var pendingTransition: Transition? = .appear

    lazy var initialTransformation = CGAffineTransform(
        scaleX: 1.7 - cgFloatDepth / 50,
        y: 1.7 - cgFloatDepth / 50
    )

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }

        updateBorderColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

//        if let superview = superview {
//            maskLayoutMarginsGuideView(with: superview)
//        }

        perform(pendingTransition) { _ in
            self.pendingTransition = .none
        }
    }

    func perform(_ transition: Transition?, completion: ((Bool) -> Void)? = .none) {
        let start: Transition.Settings
        let finish: Transition.Settings
        let delay: TimeInterval

        switch transition {
        case .none:
            return
        case .appear:
            delay = TimeInterval(depth) / 10 + .random(in: -.veryShort ... .veryShort)
            finish = (transform: .identity, alpha: 1)
            start = (transform: initialTransformation, alpha: .zero)

        case .dismiss:
            delay = 10 / TimeInterval(depth) + .random(in: -.short ... .veryShort)
            finish = (transform: initialTransformation, alpha: .zero)
            start = (transform: elementNameView.transform, alpha: alpha)
        }

        contentView.alpha = start.alpha
        elementNameView.transform = start.transform

        animate(
            withDuration: .random(in: .veryShort ... .long),
            delay: delay,
            damping: 0.7,
            animations: {
                self.contentView.alpha = finish.alpha
                self.elementNameView.transform = finish.transform
            },
            completion: completion
        )
    }

//    private func maskLayoutMarginsGuideView(with view: UIView) {
//        let path: UIBezierPath = {
//            let pathBigRect = UIBezierPath(
//                roundedRect: view.bounds,
//                byRoundingCorners: view.layer.maskedCorners.rectCorner,
//                cornerRadii: CGSize(view.layer.cornerRadius)
//            )
//
//            let pathSmallRect = UIBezierPath(rect: view.layoutMarginsGuide.layoutFrame)
//
//            pathBigRect.append(pathSmallRect)
//
//            pathBigRect.usesEvenOddFillRule = true
//
//            return pathBigRect
//        }()
//
//        layoutMarginsShadeLayer.path = path.cgPath
//
//        switch colorStyle {
//        case .light:
//            layoutMarginsGuideView.alpha = 0.11
//        case .dark:
//            layoutMarginsGuideView.alpha = 0.07
//        }
//    }

    func updateElementName() {
        name = element.elementName

        if let image = element.iconImage?.resized(CGSize(18)) {
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

// MARK: - DataReloadingProtocol

extension HighlightView: DataReloadingProtocol {
    func reloadData() {
        latestElementSnapshot = nil
        updateViewsIfNeeded()
    }
}

// MARK: - Private Helpers

private extension HighlightView {
    func setupViews(with hostView: UIView) {
        updateViews()

        contentView.installView(elementNameView, .centerX)

        verticalAlignmentConstraint.isActive = true

        updateViewsIfNeeded()

        isSafelyHidden = false

        elementNameView.enableRasterization()

        elementNameView.transform = initialTransformation

        hostView.isUserInteractionEnabled = true
    }

    private var cgFloatDepth: CGFloat { element.depth.cgFloat }

    func updateViews(isHighlighted: Bool? = nil) {
        elementNameView.tintColor = borderColor

        switch isHighlighted ?? isDragging {
        case true:
            backgroundColor = borderColor?.withAlphaComponent(colorStyle.disabledAlpha)
            borderWidth = 4 / UIScreen.main.scale

        case false:
            backgroundColor = borderColor?.withAlphaComponent(colorStyle.disabledAlpha * 0.08)
            borderWidth = 2 / UIScreen.main.scale
        }
    }
}
