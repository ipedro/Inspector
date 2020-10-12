//
//  PropertyInspectorViewReferenceSnapshotView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 12.10.20.
//

import AVFoundation
import UIKit

final class PropertyInspectorViewReferenceSnapshotView: BaseView {
    
    weak var targetView: UIView?
    
    private var displayLink: CADisplayLink? {
        didSet {
            if let oldLink = oldValue {
                oldLink.invalidate()
            }
            
            if let newLink = displayLink {
                newLink.add(to: .current, forMode: .common)
            }
        }
    }
    
    private lazy var controlsContainerView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            toggleHighlightViewsControl
        ],
        spacing: ElementInspector.appearance.verticalMargins / 2,
        margins: ElementInspector.appearance.margins
    )
    
    private(set) lazy var toggleHighlightViewsControl = ToggleControl(
        title: "highlight views",
        isOn: true
    ).then {
        $0.isShowingSeparator = false
    }
    
    private lazy var containerHeightConstraint = snapshotWrapperView.heightAnchor.constraint(
        equalToConstant: 100
    ).then {
        $0.priority = .defaultHigh
    }
    
    init(targetView: UIView?, frame: CGRect = .zero) {
        self.targetView = targetView
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var snapshotBackgroundImageView = UIImageView(
        image: IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero)
    )
    
    private lazy var statusMessageLabel = UILabel(.footnote)
    
    private lazy var snapshotContentView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            snapshotWrapperView
        ],
        margins: .margins(ElementInspector.appearance.horizontalMargins)
    ).then {
        $0.installView(snapshotBackgroundImageView, .margins(horizontal: -20, vertical: 0), .onBottom)
        $0.installView(statusMessageLabel, .centerXY)
    }
    
    private lazy var snapshotWrapperView = UIView()
    
    private var state: State = .lostConnection {
        didSet {
            snapshotWrapperView.subviews.forEach { $0.removeFromSuperview() }
            
            switch state {
            case let .snapshot(newSnapshot):
                statusMessageLabel.text = nil
                snapshotBackgroundImageView.alpha = 0.5
                
                let frame = AVMakeRect(
                    aspectRatio: CGSize(
                        width: 1,
                        height: newSnapshot.bounds.height / newSnapshot.bounds.width
                    ),
                    insideRect: CGRect(
                        origin: .zero,
                        size: CGSize(
                            width: snapshotWrapperView.bounds.width,
                            height: snapshotWrapperView.bounds.width
                        )
                    )
                )

                newSnapshot.frame = CGRect(
                    origin: CGPoint(
                        x: frame.minX,
                        y: .zero
                    ),
                    size: frame.size
                )

                if frame.size.height / UIScreen.main.bounds.height >= 1.0 {
                    newSnapshot.layer.shouldRasterize = true
                    newSnapshot.layer.rasterizationScale = 1
                }

                containerHeightConstraint.constant = frame.height

                snapshotWrapperView.addSubview(newSnapshot)
                
            case .isHidden:
                snapshotBackgroundImageView.alpha = 0.1
                statusMessageLabel.text = "View is hidden."
                
            case .lostConnection:
                snapshotBackgroundImageView.alpha = 0.1
                statusMessageLabel.text = "Lost connection to view."
                
            case .frameIsEmpty:
                snapshotBackgroundImageView.alpha = 0.1
                statusMessageLabel.text = "View frame is empty."
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(snapshotContentView)
        
        contentView.addArrangedSubview(controlsContainerView)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil else {
            displayLink = nil
            containerHeightConstraint.isActive = false
            return
        }
        
        containerHeightConstraint.isActive = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateViews))
    }
    
    enum State {
        case snapshot(UIView)
        case isHidden
        case frameIsEmpty
        case lostConnection
    }
    
    @objc private func updateViews() {
        guard let targetView = targetView else {
            displayLink = nil
            
            state = .lostConnection
            return
        }
        
        guard targetView.frame.isEmpty == false else {
            state = .frameIsEmpty
            return
        }
        
        guard targetView.isHidden == false else {
            state = .isHidden
            return
        }
        
        guard let snapshotView = targetView.snapshotView(afterScreenUpdates: false) else {
            state = .lostConnection
            return
        }
        
        state = .snapshot(snapshotView)
    }
    
    deinit {
        displayLink = nil
    }
}
