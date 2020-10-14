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
        case frameIsEmpty
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
    
    private lazy var gridImageView = UIImageView(image: IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero)).then {
        if #available(iOS 13.0, *) {
            $0.backgroundColor = .systemBackground
        } else {
            $0.backgroundColor = .darkGray
        }
    }
    
    private lazy var statusLabel = UILabel(.footnote)
    
    private lazy var snapshotContainerView = UIView(frame: bounds).then {
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
    }
    
    // MARK: - View Lifecycle
    
    override func setup() {
        super.setup()
        
        clipsToBounds = true
        
        contentMode = .scaleAspectFit
        
        isOpaque = true
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        isUserInteractionEnabled = false
        
        contentView.directionalLayoutMargins = .margins(ElementInspector.appearance.horizontalMargins)
        
        installView(gridImageView, .margins(horizontal: -20, vertical: 0), .onBottom)
        
        contentView.installView(statusLabel, .centerXY)
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard originalSnapshotSize != .zero else {
            Console.print(#function, "rasterizationScale", "skipped")
            return
        }
        
        snapshotContainerView.layer.rasterizationScale = min(UIScreen.main.scale, max(1, UIScreen.main.scale * aspectRatio))
        snapshotContainerView.layer.shouldRasterize = true
        Console.print(#function, "rasterizationScale", snapshotContainerView.layer.rasterizationScale)
        
    }
    // MARK: - State
    
    private(set) var state: State = .lostConnection {
        didSet {
            let previousSubviews = snapshotContainerView.subviews
            
            defer {
                previousSubviews.forEach { $0.removeFromSuperview() }
            }
            
            switch state {
            case let .snapshot(newSnapshot):
                
                let proportionalFrame = calculateFrame(with: newSnapshot)
                
                guard proportionalFrame != .zero else {
                    return
                }
                
                newSnapshot.contentMode = contentMode
                statusLabel.text = nil
                statusLabel.isHidden = true
                gridImageView.alpha = 0.5
                
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
                gridImageView.alpha = 0.1
                statusLabel.isHidden = showEmptyStatusMessage == false
                statusLabel.text = "View is hidden."
                
            case .lostConnection:
                gridImageView.alpha = 0.1
                statusLabel.isHidden = showEmptyStatusMessage == false
                statusLabel.text = "Lost connection to view."
                
            case .frameIsEmpty:
                gridImageView.alpha = 0.1
                statusLabel.isHidden = showEmptyStatusMessage == false
                statusLabel.text = "View frame is empty."
            }
        }
    }
    
    private func calculateFrame(with snapshot: UIView) -> CGRect {
        AVMakeRect(
            aspectRatio: CGSize(
                width: 1,
                height: snapshot.bounds.height / snapshot.bounds.width
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
            state = .frameIsEmpty
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
