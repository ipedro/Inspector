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

class HighlightView: LayerView, DraggableViewProtocol {
    var draggableAreaLayoutGuide: UILayoutGuide { safeAreaLayoutGuide }

    var isDragging: Bool = false {
        didSet {
            updateColors(isDragging: isDragging)
        }
    }

    // MARK: - Properties

    var name: String {
        didSet {
            label.text = name
        }
    }

    let colorScheme: ViewHierarchyColorScheme

    override var color: UIColor {
        didSet {
            guard color != oldValue else {
                return
            }

            labelContentView.backgroundColor = color
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

    var draggableView: UIView { labelContainerView }

    override var sourceView: UIView { draggableView }

    private lazy var verticalAlignmentConstraint = labelContainerView.centerYAnchor.constraint(equalTo: centerYAnchor)

    // MARK: - Components

    private lazy var label = UILabel().then {
        $0.font = UIFont(name: "MuktaMahee-Regular", size: 12)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.required, for: .horizontal)

        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowRadius = 1
        $0.layer.shadowOpacity = 2 / 3
    }

    private(set) lazy var labelContentView = LayerViewComponent(
        .backgroundColor(color),
        .cornerRadius(7)
    ).then {
        $0.layer.borderWidth = 1 / UIScreen.main.scale
        $0.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        $0.installView(label, .spacing(horizontal: 5.5, vertical: -1))
    }

    private lazy var labelContainerView = LayerViewComponent(
        .layerOptions(
            .shadowOffset(CGSize(width: 0, height: 1)),
            .shadowColor(UIColor.black.cgColor),
            .shadowRadius(3),
            .shadowOpacity(0.4),
            .shouldRasterize(true),
            .rasterizationScale(UIScreen.main.scale)
        )
    ).then {
        $0.installView(labelContentView, .autoResizingMask)
    }

    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(move(with:)))

    private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLayerView))

    // MARK: - Init

    init(
        frame: CGRect,
        name: String,
        colorScheme: ViewHierarchyColorScheme,
        element: ViewHierarchyElement,
        borderWidth: CGFloat = Inspector.configuration.appearance.highlightLayerBorderWidth
    ) {
        self.colorScheme = colorScheme
        self.name = name

        super.init(
            frame: frame,
            element: element,
            color: .systemGray,
            borderWidth: borderWidth
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

        labelContentView.animate(.in)
        updateColors(isDragging: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        labelContentView.animate(.out)
        updateColors()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        labelContentView.animate(.out)
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
            labelContainerView.removeFromSuperview()
            label.text = nil
            return
        }

        setupViews(with: superview)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateViews()
    }

    func updateViews() {
        updateElementName()

        updateLabelWidth()

        if let superview = superview {
            color = colorScheme.color(for: superview)
        }
    }

    func updateElementName() {
        var superViewName: String {
            guard let superview = superview else {
                return element.elementName
            }
            return superview.elementName
        }

        name = superViewName
    }
}

private extension HighlightView {
    func updateLabelWidth() {
        labelWidthConstraint?.constant = frame.width * 4 / 3
    }

    func setupViews(with hostView: UIView) {
        updateColors()

        installView(labelContainerView, .centerX)

        verticalAlignmentConstraint.isActive = true

        label.text = name

        labelWidthConstraint = label.widthAnchor.constraint(equalToConstant: frame.width).then {
            $0.priority = .defaultHigh
            $0.isActive = true
        }

        isSafelyHidden = false

        hostView.isUserInteractionEnabled = true
    }

    func updateColors(isDragging: Bool = false) {
        switch isDragging {
        case true:
            layerBackgroundColor = color.withAlphaComponent(colorStyle.disabledAlpha)
            layerBorderColor = color.withAlphaComponent(1)

        case false:
            layerBackgroundColor = color.withAlphaComponent(colorStyle.disabledAlpha / 10)
            layerBorderColor = color.withAlphaComponent(colorStyle.disabledAlpha * 2)
        }
    }
}
