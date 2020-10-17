//
//  PropertyInspectorViewThumbnailSectionView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 12.10.20.
//

import UIKit
import AVFoundation

final class PropertyInspectorViewThumbnailSectionView: BaseView {
    
    enum State {
        case snapshot(UIView)
        case isHidden
        case frameIsEmpty
        case lostConnection
    }
    
    let reference: ViewHierarchyReference
    
    private var calculatedLastFrame = 0
    
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
    
    private(set) lazy var thumbnailView = ViewHierarchyReferenceThumbnailView(
        frame: CGRect(
            origin: .zero,
            size: CGSize(
                width: frame.height,
                height: frame.height
            )
        ),
        reference: reference
    ).then {
        $0.clipsToBounds = false
    }
    
    private lazy var contentHeightConstraint = thumbnailView.heightAnchor.constraint(greaterThanOrEqualToConstant: frame.height).then {
        $0.isActive = true
    }
    
    private lazy var maxContentHeightConstraint = thumbnailView.heightAnchor.constraint(lessThanOrEqualTo: widthAnchor)
    
    init(reference: ViewHierarchyReference, frame: CGRect) {
        self.reference = reference
        
        super.init(frame: frame)
        
        guard frame.isEmpty == false else {
            return
        }
        
        widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        
        heightAnchor.constraint(equalToConstant: frame.height).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        contentView.addArrangedSubview(thumbnailView)
        
        contentView.addArrangedSubview(controlsContainerView)
        
        maxContentHeightConstraint.isActive = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview == nil else {
            return
        }
        
        stopLiveUpdatingSnaphost()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard frame.isEmpty == false else {
            return
        }
        
        updateSnapshot(afterScreenUpdates: false)
        
        switch thumbnailView.state {
        case .frameIsEmpty, .isHidden, .lostConnection:
            contentHeightConstraint.constant = ElementInspector.appearance.horizontalMargins * 4
            
        default:
            contentHeightConstraint.constant = calculateContentHeight()
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
            Console.print(#function, "skipping frame content frame calc for frame \(frame), original snapshot \(thumbnailView.originalSnapshotSize)")
            return 0
        }
        
        let height = frame.height + thumbnailView.contentView.directionalLayoutMargins.top + thumbnailView.contentView.directionalLayoutMargins.bottom
        
        return height
    }
    
    var isRedrawingViews: Bool {
        displayLink != nil
    }
    
    func startLiveUpdatingSnaphost() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(refresh)
        )
    }
    
    func stopLiveUpdatingSnaphost() {
        displayLink = nil
    }
    
    func updateSnapshot(afterScreenUpdates: Bool = true) {
        thumbnailView.updateViews(afterScreenUpdates: afterScreenUpdates)
    }
    
    @objc private func refresh() {
        guard reference.view != nil else {
            stopLiveUpdatingSnaphost()
            return
        }
        
        calculatedLastFrame += 1
        
        guard calculatedLastFrame % 2 == 0 else {
            return
        }
        
        updateSnapshot(afterScreenUpdates: false)
    }
    
    deinit {
        stopLiveUpdatingSnaphost()
    }
}
