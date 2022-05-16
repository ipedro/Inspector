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

import AVFoundation
import UIKit

class ViewHierarchyElementThumbnailView: BaseView {
    enum State {
        case snapshot(UIView)
        case frameIsEmpty(CGRect)
        case isHidden
        case lostConnection
        case noWindow
    }

    // MARK: - Properties

    let element: ViewHierarchyElementReference

    var showEmptyStatusMessage: Bool = true {
        didSet {
            updateViews(afterScreenUpdates: true)
        }
    }

    var backgroundStyle: ThumbnailBackgroundStyle {
        get {
            Inspector.sharedInstance.configuration.elementInspectorConfiguration.thumbnailBackgroundStyle
        }
        set {
            Inspector.sharedInstance.configuration.elementInspectorConfiguration.thumbnailBackgroundStyle = newValue
            backgroundColor = newValue.color
        }
    }

    private var heightConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            heightConstraint?.priority = .init(rawValue: 999)
            heightConstraint?.isActive = true
        }
    }

    // MARK: - Init

    init(with element: ViewHierarchyElementReference) {
        self.element = element
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Componentns

    private lazy var gridImageView = UIImageView(image: IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero))

    private lazy var statusContentView = UIStackView.vertical(
        .directionalLayoutMargins(contentView.directionalLayoutMargins),
        .spacing(elementInspectorAppearance.verticalMargins / 2),
        .verticalAlignment(.center)
    )

    private lazy var snapshotContainerView = BaseView().then {
        $0.layer.shadowOpacity = Float(colorStyle.disabledAlpha)
        $0.layer.shadowRadius = Self.contentMargins.leading
    }

    static let contentMargins = NSDirectionalEdgeInsets(insets: Inspector.sharedInstance.appearance.elementInspector.horizontalMargins)

    // MARK: - View Lifecycle

    override func setup() {
        super.setup()

        tintColor = colorStyle.secondaryTextColor

        contentView.directionalLayoutMargins = Self.contentMargins

        clipsToBounds = true

        contentMode = .scaleAspectFit

        isOpaque = true

        isUserInteractionEnabled = false

        installView(gridImageView, position: .behind)

        contentView.installView(statusContentView, .centerXY)

        contentView.addArrangedSubview(snapshotContainerView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = backgroundStyle.color

        guard heightConstraint == nil else { return }

        let proportionalFrame = calculateFrame(with: element.frame.size)

        guard
            !proportionalFrame.height.isNaN,
            !proportionalFrame.height.isInfinite,
            !proportionalFrame.height.isZero
        else {
            return
        }

        heightConstraint = snapshotContainerView.heightAnchor.constraint(equalToConstant: proportionalFrame.height)
    }

    var aspectRatio: CGFloat {
        switch state {
        case let .snapshot(view):
            return view.frame.width / view.frame.height

        default:
            return 3
        }
    }

    // MARK: - State

    private(set) var state: State = .lostConnection {
        didSet {
            statusContentView.subviews.forEach { $0.removeFromSuperview() }

            let previousSubviews = snapshotContainerView.contentView.arrangedSubviews

            defer {
                previousSubviews.forEach { $0.removeFromSuperview() }
            }

            switch state {
            case let .snapshot(newSnapshot):
                let proportionalFrame = calculateFrame(with: newSnapshot.bounds.size)

                guard proportionalFrame != .zero else {
                    state = .frameIsEmpty(proportionalFrame)
                    return
                }

                newSnapshot.contentMode = contentMode
                snapshotContainerView.contentView.addArrangedSubview(newSnapshot)
                heightConstraint = snapshotContainerView.heightAnchor.constraint(equalToConstant: proportionalFrame.height)

            case .isHidden:
                showStatus(icon: .eyeSlashFill, message: "View is hidden.")

            case .lostConnection:
                showStatus(icon: .wifiExlusionMark, message: Texts.lostConnectionToView)

            case let .frameIsEmpty(frame):
                showStatus(icon: .eyeSlashFill, message: "View frame is empty.\n\(frame)")

            case .noWindow:
                showStatus(icon: .wifiExlusionMark, message: "Not in the view hierarchy")
            }
        }
    }

    private func showStatus(icon glyph: Icon.Glyph, message: String) {
        statusContentView.removeAllArrangedSubviews()

        let color = backgroundStyle.contrastingColor

        let icon = Icon(glyph, color: color, size: CGSize(width: 36, height: 36))

        statusContentView.addArrangedSubview(icon)

        guard showEmptyStatusMessage else {
            return
        }

        let label = UILabel(
            .textStyle(.footnote),
            .text(message),
            .textAlignment(.center),
            .textColor(color)
        )

        statusContentView.addArrangedSubview(label)

        heightConstraint = makeEmptyHeightConstraint()
    }

    private func makeEmptyHeightConstraint() -> NSLayoutConstraint {
        contentView.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 3)
    }

    private func calculateFrame(with snapshotSize: CGSize) -> CGRect {
        Self.calculateFrame(with: snapshotSize, inside: frame)
    }

    private static func calculateFrame(with snapshotSize: CGSize, inside frame: CGRect, margins: NSDirectionalEdgeInsets = contentMargins) -> CGRect {
        let maxWidth = max(0, frame.width - margins.leading - margins.trailing)

        let rect = AVMakeRect(
            aspectRatio: CGSize(
                width: 1,
                height: snapshotSize.height / snapshotSize.width
            ),
            insideRect: CGRect(
                origin: .zero,
                size: CGSize(
                    width: maxWidth,
                    height: maxWidth
                )
            )
        )

        return rect
    }

    func updateViews(afterScreenUpdates: Bool) {
        guard let referenceView = element.underlyingView else {
            state = .lostConnection
            return
        }

        if referenceView.isAssociatedToWindow == false {
            state = .noWindow
            return
        }

        guard
            referenceView.frame.isEmpty == false,
            referenceView.frame != .zero
        else {
            state = .frameIsEmpty(referenceView.frame)
            return
        }

        guard referenceView.isHidden == false else {
            state = .isHidden
            return
        }

        guard let snapshotView = referenceView.snapshotView(afterScreenUpdates: afterScreenUpdates) else {
            state = .lostConnection
            return
        }

        state = .snapshot(snapshotView)
    }
}
