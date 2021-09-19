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

class ElementInspectorFormSectionContentView: BaseView, InspectorElementFormSectionView {
    var title: String? {
        get { header.title }
        set { header.title = newValue }
    }

    var subtitle: String? {
        get { header.subtitle }
        set { header.subtitle = newValue }
    }

    var accessoryView: UIView? {
        get { header.accessoryView }
        set { header.accessoryView = newValue }
    }

    static func createSectionView() -> InspectorElementFormSectionView {
        ElementInspectorFormSectionContentView()
    }

    // MARK: - Properties

    weak var delegate: InspectorElementFormSectionViewDelegate?

    var separatorStyle: InspectorElementFormSectionSeparatorStyle {
        get { topSeparatorView.isHidden ? .none : .top }
        set {
            switch newValue {
            case .none:
                topSeparatorView.isHidden = true
            case .top:
                topSeparatorView.isHidden = false
            }
        }
    }

    var state: InspectorElementFormSectionState {
        didSet {
            updateViewsForState()
        }
    }

    // MARK: - Views

    private lazy var formStackView = UIStackView.vertical().then {
        $0.clipsToBounds = true
    }

    private lazy var topSeparatorView = SeparatorView(style: .medium, thickness: 1)

    var header: SectionHeader

    private lazy var headerContainerControl = BaseControl(.translatesAutoresizingMaskIntoConstraints(false)).then {
        $0.addTarget(self, action: #selector(changeState), for: .touchUpInside)
        $0.addTarget(self, action: #selector(styleHeaderContainerControl), for: .stateChanged)
        $0.installView(headerStackView)
    }

    private lazy var headerStackView = UIStackView.horizontal().then {
        $0.clipsToBounds = true
        $0.spacing = ElementInspector.appearance.verticalMargins
        $0.addArrangedSubviews(collapseButton, header)
        $0.alignment = .center
    }

    private(set) lazy var collapseButton = IconButton(.chevronDown).then {
        $0.isUserInteractionEnabled = false
    }

    convenience init() {
        self.init(header: SectionHeader.attributesInspectorHeader(), frame: .zero)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let headerAccessoryView = header.accessoryView,
           headerAccessoryView.point(inside: convert(point, to: headerAccessoryView), with: event)
        {
            return headerAccessoryView
        }

        if headerContainerControl.point(inside: convert(point, to: headerContainerControl), with: event) {
            return headerContainerControl
        }

        return super.hitTest(point, with: event)
    }

    init(header: SectionHeader, state: InspectorElementFormSectionState = .collapsed, frame: CGRect = .zero) {
        self.state = state
        self.header = header

        super.init(frame: frame)
    }

    func addFormViews(_ formViews: [UIView]) {
        formStackView.addArrangedSubviews(formViews)
    }

    override func setup() {
        super.setup()

        clipsToBounds = true
        updateViewsForState()
        installSeparator()

        headerStackView.directionalLayoutMargins = .formSectionContentMargins
        formStackView.directionalLayoutMargins = .formSectionContentMargins

        contentView.addArrangedSubviews(headerContainerControl, formStackView)
    }

    private func updateViewsForState() {
        switch state {
        case .collapsed:
            hideContent(true)

        case .expanded:
            hideContent(false)
        }
    }

    private func installSeparator() {
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topSeparatorView)

        topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }

    private func hideContent(_ hide: Bool) {
        formStackView.alpha = hide ? 0 : 1
        formStackView.isSafelyHidden = hide
        collapseButton.transform = hide ? CGAffineTransform(rotationAngle: -(.pi / 2)) : .identity
    }
}

@objc private extension ElementInspectorFormSectionContentView {
    func changeState() {
        let newState: InspectorElementFormSectionState = {
            switch state {
            case .expanded:
                return .collapsed
            case .collapsed:
                return .expanded
            }
        }()

        delegate?.inspectorElementFormSectionView(self, willChangeFrom: state, to: newState)
    }

    func styleHeaderContainerControl() {
        UIView.animate(withDuration: 0.15) {
            switch self.headerContainerControl.state {
            case .highlighted:
                self.headerContainerControl.alpha = 0.77
                self.headerContainerControl.transform = .init(scaleX: 0.98, y: 0.93)
            case .disabled:
                self.headerContainerControl.alpha = self.colorStyle.disabledAlpha
                self.headerContainerControl.transform = .identity
            default:
                self.headerContainerControl.alpha = 1
                self.headerContainerControl.transform = .identity
            }
        }
    }
}

extension NSDirectionalEdgeInsets {
    static let formSectionContentMargins = ElementInspector.appearance.directionalInsets
}
