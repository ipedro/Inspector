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
        case captureFailed
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

    private lazy var heightConstraint = snapshotContainerView.heightAnchor.constraint(
        equalToConstant: .zero
    ).then {
        $0.priority = .init(rawValue: 999)
        $0.isActive = true
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

    private lazy var gridImageView = UIImageView(
        image: IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero)
    )

    private lazy var statusContentView = UIStackView().then {
        $0.axis = .vertical
        $0.isLayoutMarginsRelativeArrangement = true
        $0.directionalLayoutMargins = contentView.directionalLayoutMargins
        $0.spacing = elementInspectorAppearance.verticalMargins / 2
        $0.alignment = .center
    }

    private lazy var snapshotContainerView = BaseView().then {
        $0.layer.shadowOpacity = Float(colorStyle.disabledAlpha)
        $0.layer.shadowRadius = Self.contentMargins.leading
    }

    static let contentMargins = NSDirectionalEdgeInsets(
        Inspector.sharedInstance.appearance.elementInspector.horizontalMargins
    )

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

        let proportionalFrame = calculateFrame(with: element._frame.wrappedValue.size)

        guard
            !proportionalFrame.height.isNaN,
            !proportionalFrame.height.isInfinite,
            !proportionalFrame.height.isZero
        else {
            return
        }

        heightConstraint.constant = proportionalFrame.height
    }

    var aspectRatio: CGFloat {
        switch state {
        case let .snapshot(view):
            view.frame.width / view.frame.height

        default:
            3
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
                heightConstraint.constant = proportionalFrame.height

            case .isHidden:
                showEmptyStatus(icon: .eyeSlashFill, message: "View is hidden.")

            case .lostConnection:
                showEmptyStatus(icon: .wifiExlusionMark, message: Texts.lostConnectionToView)

            case let .frameIsEmpty(frame):
                showEmptyStatus(icon: .eyeSlashFill, message: "View frame is empty.\n\(frame)")

            case .noWindow:
                showEmptyStatus(icon: .wifiExlusionMark, message: "Not in the view hierarchy")

            case .captureFailed:
                showEmptyStatus(icon: .wifiExlusionMark, message: Texts.lostConnectionToView)
            }
        }
    }

    private func showEmptyStatus(icon glyph: Icon.Glyph, message: String) {
        statusContentView.removeAllArrangedSubviews()

        let color = backgroundStyle.contrastingColor

        let icon = Icon(glyph, color: color, size: CGSize(width: 36, height: 36))

        statusContentView.addArrangedSubview(icon)

        guard showEmptyStatusMessage else {
            return
        }

        let label = UILabel().then {
            $0.font = .preferredFont(forTextStyle: .footnote)
            $0.text = message
            $0.textAlignment = .center
            $0.textColor = color
        }

        statusContentView.addArrangedSubview(label)

        heightConstraint.constant = frame.width
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
        switch InspectorSnapshotCapture.snapshotView(
            for: element,
            afterScreenUpdates: afterScreenUpdates
        ) {
        case let .success(snapshotView):
            state = .snapshot(snapshotView)
        case let .failure(reason):
            switch reason {
            case .lostConnection:
                state = .lostConnection
            case .noWindow:
                state = .noWindow
            case let .frameIsEmpty(frame):
                state = .frameIsEmpty(frame)
            case .isHidden:
                state = .isHidden
            case .captureFailed:
                state = .captureFailed
            }
        }
    }
}
