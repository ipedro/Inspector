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
            updateViews(afterScreenUpdates: true)
        }
    }
    
    // MARK: - Init
    
    init(reference: ViewHierarchyReference, frame: CGRect = .zero) {
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
    
    private lazy var wireframeView = WireframeView(
        frame: .zero,
        reference: reference
    )
    
    // MARK: - View Lifecycle
    
    override func setup() {
        super.setup()
        
        contentMode = .scaleAspectFit
        
        clipsToBounds = true
        
        contentView.directionalLayoutMargins = .margins(ElementInspector.appearance.horizontalMargins)
        
        installView(gridImageView, .margins(horizontal: -20, vertical: 0), .onBottom)
        
        contentView.installView(statusLabel, .centerXY)
        
        contentView.addArrangedSubview(wireframeView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateViews(afterScreenUpdates: true)
    }
    
    // MARK: - State
    
    private(set) var state: State = .lostConnection {
        didSet {
            wireframeView.subviews.forEach { $0.removeFromSuperview() }
            
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
                
                wireframeView.installView(newSnapshot, .centerXY)

                let constraints = [
                    newSnapshot.widthAnchor.constraint(equalToConstant: proportionalFrame.width),
                    newSnapshot.heightAnchor.constraint(equalTo: newSnapshot.widthAnchor, multiplier: proportionalFrame.height / proportionalFrame.width),
                    newSnapshot.topAnchor.constraint(greaterThanOrEqualTo: wireframeView.topAnchor),
                    newSnapshot.leadingAnchor.constraint(greaterThanOrEqualTo: wireframeView.leadingAnchor)
                ]
                
                constraints.forEach {
                    $0.priority = .defaultHigh
                    $0.isActive = true
                }

                if proportionalFrame.size.height / UIScreen.main.bounds.height >= 1.0 {
                    newSnapshot.layer.shouldRasterize = true
                    newSnapshot.layer.rasterizationScale = 1
                }
                
                wireframeView.addSubview(newSnapshot)
                
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
                    width: wireframeView.bounds.width,
                    height: wireframeView.bounds.width
                )
            )
        )
    }
    
    func updateViews(afterScreenUpdates: Bool = false) {
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
        
        state = .snapshot(snapshotView)
    }
    
}
