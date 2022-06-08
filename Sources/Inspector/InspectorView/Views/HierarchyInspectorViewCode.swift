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

@_implementationOnly import UIKeyCommandTableView
import UIKit

protocol HierarchyInspectorViewCodeDelegate: AnyObject {
    func hierarchyInspectorViewCodeDidTapOutside(_ view: HierarchyInspectorViewCode)
}

final class HierarchyInspectorViewCode: BaseView {
    var verticalMargin: CGFloat { 30 }

    var horizontalMargin: CGFloat { verticalMargin / 2 }

    var keyboardFrame: CGRect? {
        didSet {
            let visibleHeight: CGFloat = {
                guard let keyboardFrame = keyboardFrame else {
                    return .zero
                }

                let globalFrame = convert(frame, to: nil)

                return globalFrame.height + globalFrame.origin.y - safeAreaInsets.bottom - keyboardFrame.origin.y
            }()

            bottomAnchorConstraint.constant = (visibleHeight + verticalMargin) * -1
        }
    }

    weak var delegate: HierarchyInspectorViewCodeDelegate?

    var tableViewContentSize: CGSize = .zero {
        didSet {
            debounce(#selector(updateTableViewHeight), delay: .veryShort)
        }
    }

    // MARK: - Constraints

    private lazy var tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: .zero).then {
        $0.priority = .defaultLow
        $0.isActive = true
    }

    private lazy var bottomAnchorConstraint = blurView.bottomAnchor.constraint(
        lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor,
        constant: -verticalMargin
    )

    // MARK: - Components

    private(set) lazy var searchView = HierarchyInspectorSearchView()

    private(set) lazy var tableView = UIKeyCommandTableView().then {
        $0.backgroundColor = .none
        $0.keyboardDismissMode = .interactive
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
    }

    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: colorStyle.blurStyle)

        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = elementInspectorAppearance.verticalMargins
        blurView.layer.borderWidth = 1
        blurView.layer.cornerCurve = .continuous
        blurView.layer.borderColor = {
            switch colorStyle {
            case .dark: return colorStyle.tertiaryTextColor.cgColor
            case .light: return colorStyle.quaternaryTextColor.cgColor
            }
        }()

        return blurView
    }()

    private lazy var stackView = UIStackView.vertical(
        .arrangedSubviews(
            searchView,
            tableView
        )
    )

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == .none {
            customConstraints.forEach(removeConstraint(_:))
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        updateTableViewHeight()
    }

    @objc func updateTableViewHeight() {
        guard superview?.window != nil else { return }

        let height: CGFloat = floor(tableViewContentSize.height + 1) + tableView.contentInset.verticalInsets

        guard tableViewHeightConstraint.constant != height else {
            return
        }

        UIView.performWithoutAnimation {
            self.tableViewHeightConstraint.constant = height
            self.layoutIfNeeded()
        }
    }

    private lazy var customConstraints = [
        blurView.topAnchor.constraint(equalTo:
            safeAreaLayoutGuide.topAnchor, constant: verticalMargin),
        blurView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
        blurView.widthAnchor.constraint(lessThanOrEqualTo: readableContentGuide.widthAnchor, constant: -horizontalMargin * 4),
        blurView.widthAnchor.constraint(greaterThanOrEqualToConstant: Inspector.sharedInstance.configuration.elementInspectorConfiguration.panelPreferredCompressedSize.width),
        bottomAnchorConstraint
    ]

    override func setup() {
        super.setup()

        tintColor = colorStyle.textColor
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        preservesSuperviewLayoutMargins = false

        layer.shadowColor = colorStyle.shadowColor.cgColor
        layer.shadowOffset = .init(width: 0, height: verticalMargin / 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = verticalMargin

        blurView.contentView.installView(stackView)

        contentView.addSubview(blurView)

        customConstraints.forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard
            let location = touches.first?.location(in: blurView),
            blurView.point(inside: location, with: .none) == false
        else {
            return
        }

        DispatchQueue.main.async {
            self.delegate?.hierarchyInspectorViewCodeDidTapOutside(self)
        }
    }
}

extension HierarchyInspectorViewCode: DataReloadingProtocol {
    func reloadData() {
        tableView.reloadData()
        updateTableViewHeight()
    }
}
