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
    
    private lazy var containerHeightConstraint = containerView.heightAnchor.constraint(
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
    
    private lazy var containerBackgroundImageView = UIImageView(
        image: IconKit.imageOfColorGrid().resizableImage(withCapInsets: .zero)
    )
    
    private lazy var containerView = UIView()
    
    private var viewSnapshot: UIView? {
        didSet {
            if let oldView = oldValue {
                oldView.removeFromSuperview()
            }
            
            if let newView = viewSnapshot, newView.frame.isEmpty == false {
                let frame = AVMakeRect(
                    aspectRatio: CGSize(
                        width: 1,
                        height: newView.bounds.height / newView.bounds.width
                    ),
                    insideRect: CGRect(
                        origin: .zero,
                        size: CGSize(
                            width: containerView.bounds.width,
                            height: containerView.bounds.width
                        )
                    )
                )
                
                newView.frame = CGRect(
                    origin: CGPoint(
                        x: frame.minX,
                        y: .zero
                    ),
                    size: frame.size
                )
                
                containerHeightConstraint.constant = frame.height
                
                containerView.addSubview(newView)
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        installView(containerBackgroundImageView, .margins(.zero), .onBottom)
        
        if #available(iOS 13.0, *) {
            backgroundColor = .quaternaryLabel
        }
        
        contentView.addArrangedSubview(containerView)
        
        contentView.directionalLayoutMargins = .margins(
            horizontal: ElementInspector.appearance.horizontalMargins,
            vertical: ElementInspector.appearance.horizontalMargins
        )
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
    
    @objc private func updateViews() {
        viewSnapshot = targetView?.snapshotView(afterScreenUpdates: false)
    }
    
    deinit {
        displayLink = nil
    }
}
