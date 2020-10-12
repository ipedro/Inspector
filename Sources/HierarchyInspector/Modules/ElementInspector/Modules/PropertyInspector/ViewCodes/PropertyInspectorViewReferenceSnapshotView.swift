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
        title: "show view highlights",
        isOn: true
    )
    
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
    
    private lazy var snapshotContentView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            snapshotWrapperView
        ],
        margins: .margins(ElementInspector.appearance.horizontalMargins)
    ).then {
        $0.installView(snapshotBackgroundImageView, .margins(horizontal: -20, vertical: 0), .onBottom)
        
        if #available(iOS 13.0, *) {
            $0.backgroundColor = .quaternaryLabel
        }
    }
    
    private lazy var snapshotWrapperView = UIView()
    
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
                            width: snapshotWrapperView.bounds.width,
                            height: snapshotWrapperView.bounds.width
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
                
                snapshotWrapperView.addSubview(newView)
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
    
    @objc private func updateViews() {
        viewSnapshot = targetView?.snapshotView(afterScreenUpdates: false)
    }
    
    deinit {
        displayLink = nil
    }
}
