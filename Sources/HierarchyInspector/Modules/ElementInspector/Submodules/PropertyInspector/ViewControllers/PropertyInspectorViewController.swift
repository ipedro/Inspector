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
    
    private var calculatedLastFrame = 0
    
    private lazy var viewCode = PropertyInspectorViewCode()
    
    private(set) lazy var snapshotViewCode = PropertyInspectorViewThumbnailSectionView(
        reference: viewModel.reference,
        frame: .zero
    ).then {
        $0.toggleHighlightViewsControl.isOn = !viewModel.reference.isHidingHighlightViews
        $0.toggleHighlightViewsControl.addTarget(self, action: #selector(toggleLayerInspectorViewsVisibility), for: .valueChanged)
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
        
        viewCode.contentView.addArrangedSubview(snapshotViewCode)
        
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
        viewCode.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    deinit {
        stopLiveUpdatingSnaphost()
    }
}

extension PropertyInspectorViewController {
    
    private func startLiveUpdatingSnaphost() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(refresh)
        )
    }
    
    private func stopLiveUpdatingSnaphost() {
        displayLink = nil
    }
    
    @objc private func refresh() {
        guard viewModel.reference.view != nil else {
            stopLiveUpdatingSnaphost()
            return
        }
        
        calculatedLastFrame += 1
        
        guard calculatedLastFrame % 3 == 0 else {
            return
        }
        
        let operation = MainThreadOperation(name: "udpate snapshot") { [weak self] in
            self?.snapshotViewCode.updateSnapshot(afterScreenUpdates: false)
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
    
    @objc func toggleLayerInspectorViewsVisibility() {
        let operation = MainThreadAsyncOperation(name: "toggle layers") { [weak self] in
            guard
                let self = self,
                let delegate = self.delegate
            else {
                return
            }
            
            guard self.viewModel.reference.isHidingHighlightViews else {
                delegate.propertyInspectorViewController(self, hideLayerInspectorViewsInside: self.viewModel.reference)
                return
            }
            
            delegate.propertyInspectorViewController(self, showLayerInspectorViewsInside: self.viewModel.reference)
        }
        
        delegate?.addOperationToQueue(operation)
    }
    
}

// MARK: - QueueManagerProtocol

extension PropertyInspectorViewController: OperationQueueManagerProtocol {
    func suspendQueue(_ isSuspended: Bool) {
        delegate?.suspendQueue(isSuspended)
    }
    
    func addOperationToQueue(_ operation: MainThreadOperation) {
        delegate?.addOperationToQueue(operation)
    }
}
