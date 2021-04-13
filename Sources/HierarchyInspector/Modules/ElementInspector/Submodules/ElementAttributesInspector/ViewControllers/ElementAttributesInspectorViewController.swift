//
//  ElementAttributesInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol ElementAttributesInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           didTap colorPicker: ColorPreviewControl)
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           didTap imagePicker: ImagePreviewControl)
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           didTap optionSelector: OptionListControl)
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           showLayerInspectorViewsInside reference: ViewHierarchyReference)
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           hideLayerInspectorViewsInside reference: ViewHierarchyReference)
    
}

final class ElementAttributesInspectorViewController: ElementInspectorPanelViewController {
    
    // MARK: - Properties
    
    weak var delegate: ElementAttributesInspectorViewControllerDelegate?
    
    private var viewModel: AttributesInspectorViewModelProtocol!
    
    var selectedColorPicker: ColorPreviewControl?
    
    var selectedImagePicker: ImagePreviewControl?
    
    var selectedOptionSelector: OptionListControl?
    
    private var needsInitialSnapshotRender = true
    
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
    
    private(set) lazy var viewCode = AttributesInspectorViewCode().then {
        $0.contentView.addArrangedSubview(thumbnailSectionViewCode)
        
        $0.delegate = self
    }
    
    private(set) lazy var thumbnailSectionViewCode = AttributesInspectorThumbnailSectionView(
        reference: viewModel.reference,
        frame: .zero
    ).then {
        $0.referenceDetailView.viewModel = viewModel
        
        $0.isHighlightingViewsControl.isOn = viewModel.isHighlightingViews
        
        $0.isLiveUpdatingControl.isOn = viewModel.isLiveUpdating
        
        $0.isHighlightingViewsControl.addTarget(self, action: #selector(toggleHighlightViews), for: .valueChanged)
        
        $0.isLiveUpdatingControl.addTarget(self, action: #selector(toggleLiveUpdate), for: .valueChanged)
        
        $0.referenceAccessoryButton.addTarget(self, action: #selector(tapThumbnailAccessory), for: .touchUpInside)
    }
    
    // MARK: - Init
    
    static func create(viewModel: AttributesInspectorViewModelProtocol) -> ElementAttributesInspectorViewController {
        let viewController = ElementAttributesInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        renderInitialSnapshotIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        debounce(#selector(startLiveUpdatingSnaphost), after: ElementInspector.configuration.animationDuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopLiveUpdatingSnaphost()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        guard parent == nil else {
            return
        }
        
        stopLiveUpdatingSnaphost()
    }
    
    deinit {
        stopLiveUpdatingSnaphost()
    }
    
    func animatePanel(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        stopLiveUpdatingSnaphost()
        
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration * 2,
            delay: 0.05,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
            animations: animations
        ) { [weak self] finished in
            
            completion?(finished)
            
            self?.startLiveUpdatingSnaphost()
        }
    }
}


@objc extension ElementAttributesInspectorViewController {
    
    func updateHeaderDetails() {
        thumbnailSectionViewCode.referenceDetailView.viewModel = viewModel
    }
        
    func updateHeaderSnapshot() {
        thumbnailSectionViewCode.updateSnapshot(afterScreenUpdates: false)
    }
    
    func startLiveUpdatingSnaphost() {
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }
    
    func stopLiveUpdatingSnaphost() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(startLiveUpdatingSnaphost),
            object: nil
        )
        
        displayLink = nil
    }
    
    func refresh() {
        guard viewModel.reference.rootView != nil else {
            return stopLiveUpdatingSnaphost()
        }
        
        guard viewCode.isPointerInUse == false, viewModel.isLiveUpdating else {
            return
        }
        
        let operation = MainThreadAsyncOperation(name: "udpate snapshot") { [weak self] in
            self?.thumbnailSectionViewCode.updateSnapshot(afterScreenUpdates: false)
        }
        
        delegate?.addOperationToQueue(operation)
    }
}

// MARK: - API

extension ElementAttributesInspectorViewController {
    
    func calculatePreferredContentSize() -> CGSize {
        viewCode.contentView.systemLayoutSizeFitting(
            ElementInspector.appearance.panelPreferredCompressedSize,
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func selectImage(_ image: UIImage?) {
        selectedImagePicker?.updateSelectedImage(image)
    }
    
    func selectColor(_ color: UIColor) {
        selectedColorPicker?.updateSelectedColor(color)
    }
    
    func selectOptionAtIndex(_ index: Int?) {
        selectedOptionSelector?.updateSelectedIndex(index)
    }
        
    func finishColorSelection() {
        selectedColorPicker = nil
    }
    
    func finishOptionSelction() {
        selectedOptionSelector = nil
    }
    
}

// MARK: - Actions

private extension ElementAttributesInspectorViewController {
    
    func renderInitialSnapshotIfNeeded() {
        guard needsInitialSnapshotRender else {
            return
        }
        
        needsInitialSnapshotRender = false
        refresh()
    }
    
    func loadSections() {
        updateHeaderDetails()
        updateHeaderSnapshot()
        
        viewModel.sectionViewModels.enumerated().forEach { index, sectionViewModel in
            
            let sectionViewController = AttributesInspectorSectionViewController.create(viewModel: sectionViewModel).then {
                $0.isCollapsed = index > 0
                $0.delegate = self
            }
            
            addChild(sectionViewController)
            
            viewCode.contentView.addArrangedSubview(sectionViewController.view)
            
            sectionViewController.didMove(toParent: self)
        }
    }
    
    @objc
    func toggleHighlightViews() {
        let operation = MainThreadAsyncOperation(name: "toggle layers") { [weak self] in
            guard
                let self = self,
                let delegate = self.delegate
            else {
                return
            }
            
            guard self.viewModel.isHighlightingViews else {
                delegate.attributesInspectorViewController(self, showLayerInspectorViewsInside: self.viewModel.reference)
                return
            }
            
            delegate.attributesInspectorViewController(self, hideLayerInspectorViewsInside: self.viewModel.reference)
        }
        
        delegate?.addOperationToQueue(operation)
    }
    
    @objc
    func toggleLiveUpdate() {
        viewModel.isLiveUpdating.toggle()
    }
    
    @objc
    func tapThumbnailAccessory() {
        animatePanel { [weak self] in
            self?.thumbnailSectionViewCode.toggleAccessoryControls()
        }
    }
}

// MARK: - QueueManagerProtocol

extension ElementAttributesInspectorViewController: OperationQueueManagerProtocol {
    
    func cancelAllOperations() {
        delegate?.cancelAllOperations()
    }
    
    func suspendQueue(_ isSuspended: Bool) {
        delegate?.suspendQueue(isSuspended)
    }
    
    func addOperationToQueue(_ operation: MainThreadOperation) {
        delegate?.addOperationToQueue(operation)
    }
    
}

// MARK: - AttributesInspectorViewCodeDelegate

extension ElementAttributesInspectorViewController: AttributesInspectorViewCodeDelegate {
    
    func attributesInspectorViewCode(_ viewCode: AttributesInspectorViewCode, isPointerInUse: Bool) {
        thumbnailSectionViewCode.isLiveUpdatingControl.isEnabled = isPointerInUse == false
        thumbnailSectionViewCode.isLiveUpdatingControl.setOn(isPointerInUse == false && viewModel.isLiveUpdating, animated: true)
    }
    
}
