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
    
    private(set) var displayLink: CADisplayLink? {
        didSet {
            if let oldLink = oldValue {
                oldLink.invalidate()
            }
            
            if let newLink = displayLink {
                newLink.add(to: .current, forMode: .default)
            }
        }
    }
    
    private lazy var viewCode = AttributesInspectorViewCode().then {
        $0.delegate = self
    }
    
    private(set) lazy var thumbnailSectionViewCode = AttributesInspectorViewThumbnailSectionView(
        reference: viewModel.reference,
        frame: .zero
    ).then {
        $0.isHighlightingViewsControl.isOn = viewModel.isHighlightingViews
        
        $0.isLiveUpdatingControl.isOn = viewModel.isLiveUpdating
        
        $0.isHighlightingViewsControl.addTarget(self, action: #selector(toggleHighlightViews), for: .valueChanged)
        
        $0.isLiveUpdatingControl.addTarget(self, action: #selector(toggleLiveUpdate), for: .valueChanged)
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
        
        viewCode.contentView.addArrangedSubview(thumbnailSectionViewCode)
        
        viewCode.headerCell.viewModel = viewModel
        
        loadSections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startLiveUpdatingSnaphost()
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
    
    func calculatePreferredContentSize() -> CGSize {
        viewCode.contentView.systemLayoutSizeFitting(
            ElementInspector.appearance.panelPreferredCompressedSize,
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    deinit {
        stopLiveUpdatingSnaphost()
    }
}


private extension ElementAttributesInspectorViewController {
    
    func startLiveUpdatingSnaphost() {
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }
    
    func stopLiveUpdatingSnaphost() {
        displayLink = nil
    }
    
    @objc
    func refresh() {
        guard viewModel.reference.view != nil else {
            stopLiveUpdatingSnaphost()
            return
        }
        
        guard viewCode.isPointerInUse == false, viewModel.isLiveUpdating else {
            return
        }
        
        let operation = MainThreadOperation(name: "udpate snapshot") { [weak self] in
            self?.thumbnailSectionViewCode.updateSnapshot(afterScreenUpdates: false)
        }
        
        delegate?.addOperationToQueue(operation)
    }
}

// MARK: - API

extension ElementAttributesInspectorViewController {
    
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
    
    func loadSections() {
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
