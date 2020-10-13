//
//  PropertyInspectorViewThumbnailSectionView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 12.10.20.
//

import UIKit

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
    
    private lazy var thumbnailView = ViewHierarchyReferenceThumbnailView(
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
    
    init(reference: ViewHierarchyReference, frame: CGRect = .zero) {
        self.reference = reference
        
        super.init(frame: frame)
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
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview == nil else {
            return
        }
        
        stopLiveUpdatingSnaphost()
    }
    
    var isRedrawingViews: Bool {
        displayLink != nil
    }
    
    func startLiveUpdatingSnaphost() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateSnapshot))
    }
    
    func stopLiveUpdatingSnaphost() {
        displayLink = nil
    }
    
    @objc private func updateSnapshot() {
        guard reference.view != nil else {
            stopLiveUpdatingSnaphost()
            return
        }
        
        calculatedLastFrame = (calculatedLastFrame + 1) % 3
        
        guard calculatedLastFrame == 1 else {
            return
        }
        
        thumbnailView.updateViews(afterScreenUpdates: false)
    }
    
    deinit {
        stopLiveUpdatingSnaphost()
    }
}
