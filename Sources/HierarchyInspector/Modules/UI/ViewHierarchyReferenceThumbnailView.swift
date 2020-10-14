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
        case isHidden
        case frameIsEmpty(CGRect)
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
        image: IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero)
    )
    
    private lazy var statusContentView = UIStackView(
        axis: .vertical,
        spacing: ElementInspector.appearance.verticalMargins / 2,
        margins: contentView.directionalLayoutMargins
    ).then {
        $0.alignment = .center
    }
    
    private lazy var snapshotContainerView = UIView(frame: bounds).then {
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
    }
    
    // MARK: - View Lifecycle
    
    override func setup() {
        super.setup()
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        contentView.directionalLayoutMargins = .margins(ElementInspector.appearance.horizontalMargins)
        
        clipsToBounds = true
        
        contentMode = .scaleAspectFit
        
        isOpaque = true
        
        isUserInteractionEnabled = false
        
        installView(gridImageView, .margins(.zero), .onBottom)
        
        contentView.installView(statusContentView)
        
        contentView.addArrangedSubview(snapshotContainerView)
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
            
            backgroundColor = ElementInspector.appearance.panelHighlightBackgroundColor
            
            let previousSubviews = snapshotContainerView.subviews
            
            defer {
                previousSubviews.forEach { $0.removeFromSuperview() }
            }
            
            switch state {
            case let .snapshot(newSnapshot):
                backgroundColor = ElementInspector.appearance.tertiaryTextColor
                
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
        
        let color = ElementInspector.appearance.secondaryTextColor
        
        let icon = Icon(glyph, color: color, size: CGSize(width: 36, height: 36))
        
        statusContentView.addArrangedSubview(icon)
        
        guard showEmptyStatusMessage else {
            return
        }
        
        let label = UILabel.init(.footnote, text, textAlignment: .center, textColor: color)
        
        statusContentView.addArrangedSubview(label)
    }
    
    private func calculateFrame(with snapshotSize: CGSize) -> CGRect {
        AVMakeRect(
            aspectRatio: CGSize(
                width: 1,
                height: snapshotSize.height / snapshotSize.width //snapshot.bounds.height / snapshot.bounds.width
            ),
            insideRect: CGRect(
                origin: .zero,
                size: CGSize(
                    width:  max(0, bounds.width - contentView.directionalLayoutMargins.leading - contentView.directionalLayoutMargins.trailing),
                    height: max(0, bounds.width - contentView.directionalLayoutMargins.leading - contentView.directionalLayoutMargins.trailing)
                )
            )
        )
    }
    
    func updateViews(afterScreenUpdates: Bool = true) {
        guard let referenceView = reference.view else {
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
