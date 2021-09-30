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

class ElementInspectorFormItemContentView: BaseView, InspectorElementFormItemView {
    var title: String? {
        get { header.title }
        set { header.title = newValue }
    }

    var subtitle: String? {
        get { header.subtitle }
        set { header.subtitle = newValue }
    }

    static func makeItemView() -> InspectorElementFormItemView {
        ElementInspectorFormItemContentView(header: SectionHeader.formSectionTitle(), frame: .zero)
    }

    // MARK: - Properties

    weak var delegate: InspectorElementFormItemViewDelegate?

    var separatorStyle: InspectorElementFormItemSeparatorStyle = .none {
        didSet {
            switch separatorStyle {
            case .none:
                topSeparatorView.isHidden = true
                bottomSeparatorView.isHidden = true
            case .top:
                topSeparatorView.isHidden = false
                bottomSeparatorView.isHidden = true
            case .bottom:
                topSeparatorView.isHidden = true
                bottomSeparatorView.isHidden = false
            }
        }
    }

    var state: InspectorElementFormItemState {
        didSet {
            updateViewsForState()
        }
    }

    // MARK: - Views

    private(set) lazy var formStackView = UIStackView.vertical().then {
        $0.clipsToBounds = true
    }

    private lazy var topSeparatorView = SeparatorView(style: .hard).then {
        $0.isSafelyHidden = true
    }

    private lazy var bottomSeparatorView = SeparatorView(style: .hard).then {
        $0.isSafelyHidden = true
    }

    var header: SectionHeader

    private lazy var headerStackView = UIStackView.horizontal().then {
        $0.isLayoutMarginsRelativeArrangement = true
        $0.alignment = .center
        $0.addArrangedSubview(headerControl)
        $0.clipsToBounds = true
    }

    func addHeaderArrangedSubviews(_ views: UIView...) {
        headerStackView.addArrangedSubviews(views)
    }

    private lazy var headerControl = BaseControl(.translatesAutoresizingMaskIntoConstraints(false)).then {
        $0.addTarget(self, action: #selector(changeState), for: .touchUpInside)
        $0.addTarget(self, action: #selector(headerControlDidChangeState), for: .stateChanged)

        $0.contentView.isUserInteractionEnabled = false
        $0.contentView.spacing = ElementInspector.appearance.verticalMargins
        $0.contentView.addArrangedSubviews(collapseButton, header)
        $0.contentView.alignment = .center
        $0.contentView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
    }

    private(set) lazy var collapseButton = IconButton(.chevronDown).then {
        $0.isUserInteractionEnabled = false
    }

    init(header: SectionHeader,
         state: InspectorElementFormItemState = .collapsed, frame: CGRect = .zero) {
        self.state = state
        self.header = header

        super.init(frame: frame)
    }

    func addFormViews(_ formViews: [UIView]) {
        contentView.spacing = formViews.first is NoteControl ? .zero : ElementInspector.appearance.verticalMargins
        formStackView.addArrangedSubviews(formViews)
    }

    override func setup() {
        super.setup()

        if #available(iOS 13.0, *) {
            let interaction = UIContextMenuInteraction(delegate: self)
            headerControl.addInteraction(interaction)
        }

        clipsToBounds = true
        updateViewsForState()
        installSeparators()

        headerControl.contentView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets
        formStackView.directionalLayoutMargins = ElementInspector.appearance.directionalInsets.with(top: .zero)

        contentView.addArrangedSubviews(headerStackView, formStackView)
    }

    private func updateViewsForState() {
        switch state {
        case .collapsed:
            hideContent(true)

        case .expanded:
            hideContent(false)
        }
    }

    private func installSeparators() {
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparatorView)
        topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomSeparatorView)
        bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func hideContent(_ hide: Bool) {
        formStackView.alpha = hide ? 0 : 1
        formStackView.isSafelyHidden = hide
        collapseButton.transform = hide ? CGAffineTransform(rotationAngle: -(.pi / 2)) : .identity
    }
}

@objc private extension ElementInspectorFormItemContentView {
    func changeState() {
        var newState = state
        newState.toggle()

        delegate?.inspectorElementFormItemView(self, willChangeFrom: state, to: newState)
    }

    func headerControlDidChangeState() {
        animate {
            switch self.headerControl.state {
            case .highlighted:
                self.headerControl.alpha = 0.66
                self.headerControl.transform = .init(scaleX: 0.98, y: 0.93)
            default:
                self.headerControl.alpha = 1
                self.headerControl.transform = .identity
            }
        }
    }
}

// MARK: - UIContextMenuInteractionDelegate

@available(iOS 13.0, *)
extension ElementInspectorFormItemContentView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { [weak self] _ in
                guard let self = self else { return nil }

                return UIMenu(
                    title: String(),
                    image: nil,
                    identifier: nil,
                    options: .displayInline,
                    children: [
                        UIAction.collapseAction(self.state == .collapsed) { [weak self] _ in
                            self?.changeState()
                        }
                    ]
                )
            }
        )
    }
}
