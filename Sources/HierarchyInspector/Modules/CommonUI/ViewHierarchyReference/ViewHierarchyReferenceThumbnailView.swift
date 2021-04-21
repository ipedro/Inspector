//
//  ViewHierarchyReferenceThumbnailView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 12.10.20.
//

import AVFoundation
import UIKit

final class ViewHierarchyReferenceThumbnailView: BaseView {
    
    enum State {
        case snapshot(UIView)
        case frameIsEmpty(CGRect)
        case isHidden
        case lostConnection
    }
    
    // MARK: - Properties
    
    let reference: ViewHierarchyReference
    
    var showEmptyStatusMessage: Bool = true {
        didSet {
            updateViews()
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
    
    init(frame: CGRect, reference: ViewHierarchyReference) {
        self.reference = reference
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Componentns
    
    private lazy var gridImageView = UIImageView(
        .image(IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero))
    )
    
    private lazy var statusContentView = UIStackView.vertical(
        .directionalLayoutMargins(contentView.directionalLayoutMargins),
        .spacing(ElementInspector.appearance.verticalMargins / 2),
        .alignment(.center)
    )
    
    private lazy var snapshotContainerView = UIView(
        .layerOptions(.masksToBounds(true)),
        .clipsToBounds(true),
        .frame(bounds)
    )
    
    // MARK: - View Lifecycle
    
    override func setup() {
        super.setup()
        
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(ElementInspector.appearance.horizontalMargins)
        
        clipsToBounds = true
        
        contentMode = .scaleAspectFit
        
        isOpaque = true
        
        isUserInteractionEnabled = false
        
        installView(gridImageView, .margins(.zero), position: .behind)
        
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
            return 0
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
                
            case .isHidden:
                installStatusView(icon: .eyeSlashFill, text: "View is hidden.")
                
            case .lostConnection:
                installStatusView(icon: .wifiExlusionMark, text: "Lost connection to view.")
                
            case let .frameIsEmpty(frame):
                installStatusView(icon: .eyeSlashFill, text: "View frame is empty.\n\(frame)")
            }
        }
    }
    
    private func installStatusView(icon glyph: Icon.Glyph, text: String) {
        statusContentView.subviews.forEach { $0.removeFromSuperview() }
        
        let color = backgroundStyle.contrastingColor
        
        let icon = Icon(glyph, color: color, size: CGSize(width: 36, height: 36))
        
        statusContentView.addArrangedSubview(icon)
        
        guard showEmptyStatusMessage else {
            return
        }
        
        let label = UILabel(
            .textStyle(.footnote),
            .text(text),
            .textAlignment(.center),
            .textColor(color)
        )
        
        statusContentView.addArrangedSubview(label)
    }
    
    private func calculateFrame(with snapshotSize: CGSize) -> CGRect {
        let margins  = contentView.directionalLayoutMargins
        let maxWidth = max(0, bounds.width - margins.leading - margins.trailing)
        
        return AVMakeRect(
            aspectRatio: CGSize(
                width: 1,
                height: snapshotSize.height / snapshotSize.width
            ),
            insideRect: CGRect(
                origin: .zero,
                size: CGSize(
                    width:  maxWidth,
                    height: maxWidth
                )
            )
        )
    }
    
    func updateViews(afterScreenUpdates: Bool = true) {
        guard let referenceView = reference.rootView else {
            state = .lostConnection
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
