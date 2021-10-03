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

    let element: ViewHierarchyElement

    var showEmptyStatusMessage: Bool = true {
        didSet {
            updateViews(afterScreenUpdates: true)
        }
    }

    private(set) var originalSnapshotSize: CGSize = .zero

    var backgroundStyle: ThumbnailBackgroundStyle {
        get {
            ElementInspector.configuration.thumbnailBackgroundStyle
        }
        set {
            ElementInspector.configuration.thumbnailBackgroundStyle = newValue
            backgroundColor = newValue.color
        }
    }

    // MARK: - Init

    init(frame: CGRect, element: ViewHierarchyElement) {
        self.element = element

        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Componentns

    private lazy var emptyHeightConstraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: aspectRatio).then {
        $0.priority = .defaultHigh
    }

    private lazy var gridImageView = UIImageView(
        .image(IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero))
    )

    private lazy var statusContentView = UIStackView.vertical(
        .directionalLayoutMargins(contentView.directionalLayoutMargins),
        .spacing(ElementInspector.appearance.verticalMargins / 2),
        .verticalAlignment(.center)
    )

    private lazy var snapshotContainerView = UIView(
        .layerOptions(.masksToBounds(true)),
        .clipsToBounds(true),
        .frame(bounds)
    )

    // MARK: - View Lifecycle

    override func setup() {
        super.setup()

        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(insets: ElementInspector.appearance.horizontalMargins)

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
    }

    var aspectRatio: CGFloat {
        guard
            snapshotContainerView.frame.isEmpty == false,
            originalSnapshotSize != .zero
        else {
            return 3
        }

        return snapshotContainerView.frame.size.width / originalSnapshotSize.width
    }

    // MARK: - State

    private(set) var state: State = .lostConnection {
        didSet {
            statusContentView.subviews.forEach { $0.removeFromSuperview() }

            let previousSubviews = snapshotContainerView.subviews

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
                snapshotContainerView.installView(newSnapshot, .centerXY)

                let constraints = [
                    newSnapshot.widthAnchor.constraint(equalToConstant: proportionalFrame.width),
                    newSnapshot.heightAnchor.constraint(equalTo: newSnapshot.widthAnchor, multiplier: proportionalFrame.height / proportionalFrame.width),
                    newSnapshot.topAnchor.constraint(greaterThanOrEqualTo: snapshotContainerView.topAnchor),
                    newSnapshot.leadingAnchor.constraint(greaterThanOrEqualTo: snapshotContainerView.leadingAnchor),
                    newSnapshot.bottomAnchor.constraint(lessThanOrEqualTo: snapshotContainerView.bottomAnchor)
                ]

                constraints.forEach {
                    $0.priority = .defaultHigh
                    $0.isActive = true
                }

                snapshotContainerView.addSubview(newSnapshot)
                emptyHeightConstraint.isActive = false

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
        emptyHeightConstraint.isActive = true

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
    }

    private func calculateFrame(with snapshotSize: CGSize) -> CGRect {
        let margins = contentView.directionalLayoutMargins
        let maxWidth = max(0, bounds.width - margins.leading - margins.trailing)

        return AVMakeRect(
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
    }

    func updateViews(afterScreenUpdates: Bool) {
        guard let referenceView = element.rootView else {
            state = .lostConnection
            return
        }

        guard referenceView.window != nil else {
            state = .noWindow
            return
        }

        guard referenceView.frame.isEmpty == false, referenceView.frame != .zero else {
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

        originalSnapshotSize = snapshotView.frame.size

        state = .snapshot(snapshotView)
    }
}

final class LiveViewHierarchyElementThumbnailView: ViewHierarchyElementThumbnailView {
    override var isHidden: Bool {
        didSet {
            if isHidden {
                stopLiveUpdatingSnaphost()
            }
            else {
                startLiveUpdatingSnaphost()
            }
        }
    }

    private var displayLink: CADisplayLink? {
        didSet {
            if let oldLink = oldValue {
                oldLink.invalidate()
            }

            if let newLink = displayLink {
                newLink.add(to: .current, forMode: .default)
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard superview?.window != nil else {
            return stopLiveUpdatingSnaphost()
        }

        startLiveUpdatingSnaphost()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard let window = window else {
            if #available(iOS 13.0, *) {
                hoverGestureRecognizer.isEnabled = false
            }

            return stopLiveUpdatingSnaphost()
        }

        if #available(iOS 13.0, *) {
            window.addGestureRecognizer(hoverGestureRecognizer)
            hoverGestureRecognizer.isEnabled = true
        }

        if #available(iOS 14.0, *) {
            hoverGestureRecognizer.isEnabled = ProcessInfo().isiOSAppOnMac == false
        }

        startLiveUpdatingSnaphost()
    }

    @objc
    func startLiveUpdatingSnaphost() {
        debounce(#selector(makeDisplayLink), after: .average)
    }

    @objc
    func makeDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }

    @objc
    func stopLiveUpdatingSnaphost() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(makeDisplayLink),
            object: nil
        )

        displayLink = nil
    }

    @objc
    func refresh() {
        guard
            let rootView = element.rootView,
            rootView.window != nil
        else {
            return stopLiveUpdatingSnaphost()
        }

        if backgroundStyle.color != backgroundColor {
            backgroundColor = backgroundStyle.color
        }

        if !isHidden, superview?.isHidden == false {
            updateViews(afterScreenUpdates: false)
        }
    }

    @available(iOS 13.0, *)
    private lazy var hoverGestureRecognizer = UIHoverGestureRecognizer(
        target: self,
        action: #selector(hovering(_:))
    )

    @available(iOS 13.0, *)
    @objc
    func hovering(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            stopLiveUpdatingSnaphost()

        case .ended, .cancelled:
            startLiveUpdatingSnaphost()

        default:
            break
        }
    }
}
