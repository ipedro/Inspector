//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         didTap colorPicker: ColorPicker)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         didTap imagePicker: ImagePicker)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         didTap optionSelector: OptionSelector)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         showLayerInspectorViewsInside reference: ViewHierarchyReference)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         hideLayerInspectorViewsInside reference: ViewHierarchyReference)
    
}

final class PropertyInspectorViewController: ElementInspectorPanelViewController {
    
    // MARK: - Properties
    
    weak var delegate: PropertyInspectorViewControllerDelegate?
    
    private var viewModel: PropertyInspectorViewModelProtocol!
    
    var selectedColorPicker: ColorPicker?
    
    var selectedImagePicker: ImagePicker?
    
    var selectedOptionSelector: OptionSelector?
    
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
    
    private lazy var viewCode = PropertyInspectorViewCode().then {
        $0.delegate = self
    }
    
    private(set) lazy var thumbnailSectionViewCode = PropertyInspectorViewThumbnailSectionView(
        reference: viewModel.reference,
        frame: .zero
    ).then {
        $0.isHighlightingViewsControl.isOn = viewModel.isHighlightingViews
        
        $0.isLiveUpdatingControl.isOn = viewModel.isLiveUpdating
        
        $0.isHighlightingViewsControl.addTarget(self, action: #selector(toggleHighlightViews), for: .valueChanged)
        
        $0.isLiveUpdatingControl.addTarget(self, action: #selector(toggleLiveUpdate), for: .valueChanged)
    }
    
    // MARK: - Init
    
    static func create(viewModel: PropertyInspectorViewModelProtocol) -> PropertyInspectorViewController {
        let viewController = PropertyInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCode.elementNameLabel.text = viewModel.reference.elementName
        
        viewCode.elementDescriptionLabel.text = viewModel.reference.elementDescription
        
        viewCode.contentView.addArrangedSubview(thumbnailSectionViewCode)
        
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
            ElementInspector.configuration.appearance.panelPreferredCompressedSize,
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    deinit {
        stopLiveUpdatingSnaphost()
    }
}

private extension PropertyInspectorViewController {
    
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

extension PropertyInspectorViewController {
    
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

private extension PropertyInspectorViewController {
    
    func loadSections() {
        viewModel.sectionViewModels.enumerated().forEach { index, sectionViewModel in
            
            let sectionViewController = PropertyInspectorSectionViewController.create(viewModel: sectionViewModel).then {
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
                delegate.propertyInspectorViewController(self, showLayerInspectorViewsInside: self.viewModel.reference)
                return
            }
            
            delegate.propertyInspectorViewController(self, hideLayerInspectorViewsInside: self.viewModel.reference)
        }
        
        delegate?.addOperationToQueue(operation)
    }
    
    @objc
    func toggleLiveUpdate() {
        viewModel.isLiveUpdating.toggle()
    }
    
}

// MARK: - QueueManagerProtocol

extension PropertyInspectorViewController: OperationQueueManagerProtocol {
    
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

// MARK: - PropertyInspectorViewCodeDelegate

extension PropertyInspectorViewController: PropertyInspectorViewCodeDelegate {
    
    func propertyInspectorViewCode(_ viewCode: PropertyInspectorViewCode, isPointerInUse: Bool) {
        thumbnailSectionViewCode.isLiveUpdatingControl.isEnabled = isPointerInUse == false
        thumbnailSectionViewCode.isLiveUpdatingControl.setOn(isPointerInUse == false && viewModel.isLiveUpdating, animated: true)
    }
    
}
