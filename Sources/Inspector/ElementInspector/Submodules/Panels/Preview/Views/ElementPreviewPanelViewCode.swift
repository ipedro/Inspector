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

protocol ElementPreviewPanelViewCodeDelegate: AnyObject {
    func elementPreviewPanelViewCode(_ view: ElementPreviewPanelViewCode, isPointerInUse: Bool)
}

final class ElementPreviewPanelViewCode: BaseView {
    let reference: ViewHierarchyElement

    weak var delegate: ElementPreviewPanelViewCodeDelegate?

    private(set) var isPointerInUse = false {
        didSet {
            delegate?.elementPreviewPanelViewCode(self, isPointerInUse: isPointerInUse)
        }
    }

    private lazy var header = SectionHeader.formSectionTitle(title: "Preview").then {
        $0.margins = ElementInspector.appearance.directionalInsets
    }

    private lazy var controlsContainerView = UIStackView.vertical(
        .directionalLayoutMargins(horizontal: ElementInspector.appearance.horizontalMargins),
        .arrangedSubviews(
            backgroundAppearanceControl,
            isHighlightingViewsControl,
            isLiveUpdatingControl
        )
    )

    private lazy var backgroundAppearanceControl = SegmentedControl(
        title: "Background Appearance",
        images: ThumbnailBackgroundStyle.allCases.map(\.image),
        selectedIndex: thumbnailView.backgroundStyle.rawValue
    ).then {
        $0.axis = .horizontal
        $0.addTarget(self, action: #selector(changeBackground), for: .valueChanged)
    }

    private(set) lazy var isHighlightingViewsControl = ToggleControl(
        title: "Highlight Views",
        isOn: true
    )

    private(set) lazy var isLiveUpdatingControl = ToggleControl(
        title: "Live Update",
        isOn: true
    ).then {
        $0.isShowingSeparator = false
    }

    private(set) lazy var thumbnailView = ViewHierarchyElementThumbnailView(
        frame: .zero,
        reference: reference
    ).then {
        $0.clipsToBounds = false
    }

    private lazy var thumbnailHeightConstraint = thumbnailView.heightAnchor.constraint(
        greaterThanOrEqualToConstant: frame.height
    ).then {
        $0.priority = .defaultHigh
        $0.isActive = true
    }

    init(reference: ViewHierarchyElement, frame: CGRect) {
        self.reference = reference

        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        contentView.addArrangedSubviews(
            header,
            thumbnailView,
            controlsContainerView,
            UIView()
        )

        contentView.setCustomSpacing(ElementInspector.appearance.horizontalMargins, after: controlsContainerView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard frame.isEmpty == false else {
            return
        }

        switch thumbnailView.state {
        case .frameIsEmpty, .isHidden, .lostConnection:
            thumbnailHeightConstraint.constant = ElementInspector.appearance.horizontalMargins * 4

        default:
            thumbnailHeightConstraint.constant = calculateContentHeight()
        }
    }

    private func calculateContentHeight() -> CGFloat {
        let frame = AVMakeRect(
            aspectRatio: CGSize(
                width: 1,
                height: thumbnailView.originalSnapshotSize.height / thumbnailView.originalSnapshotSize.width
            ),
            insideRect: CGRect(
                origin: .zero,
                size: CGSize(width: bounds.width, height: bounds.width * 2 / 3)
            )
        )

        guard frame.height.isNormal else {
            Console.log(#function, "skipping frame content frame calc for frame \(frame), original snapshot \(thumbnailView.originalSnapshotSize)")
            return 0
        }

        let height = frame.height + thumbnailView.contentView.directionalLayoutMargins.top + thumbnailView.contentView.directionalLayoutMargins.bottom

        return height
    }

    func updateSnapshot(afterScreenUpdates: Bool = true) {
        thumbnailView.updateViews(afterScreenUpdates: afterScreenUpdates)
    }

    @objc
    func changeBackground() {
        guard
            let selectedIndex = backgroundAppearanceControl.selectedIndex,
            let backgroundStyle = ThumbnailBackgroundStyle(rawValue: selectedIndex)
        else {
            thumbnailView.backgroundStyle = .strong
            return
        }

        thumbnailView.backgroundStyle = backgroundStyle
    }

    @available(iOS 13.0, *)
    private lazy var hoverGestureRecognizer = UIHoverGestureRecognizer(
        target: self,
        action: #selector(hovering(_:))
    )

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard let window = window else {
            if #available(iOS 13.0, *) {
                hoverGestureRecognizer.isEnabled = false
            }

            return
        }

        if #available(iOS 13.0, *) {
            window.addGestureRecognizer(hoverGestureRecognizer)
            hoverGestureRecognizer.isEnabled = true
        }

        if #available(iOS 14.0, *) {
            hoverGestureRecognizer.isEnabled = ProcessInfo().isiOSAppOnMac == false
        }
    }

    @available(iOS 13.0, *)
    @objc
    func hovering(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            isPointerInUse = true

        case .ended, .cancelled:
            isPointerInUse = false

        default:
            break
        }
    }
}
