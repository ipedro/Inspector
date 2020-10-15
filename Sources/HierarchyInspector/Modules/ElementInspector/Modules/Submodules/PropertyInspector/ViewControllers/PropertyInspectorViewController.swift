//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewControllerDelegate: AnyObject {
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTap colorPicker: ColorPicker)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTap optionSelector: OptionSelector)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, showLayerInspectorViewsInside reference: ViewHierarchyReference)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, hideLayerInspectorViewsInside reference: ViewHierarchyReference)
    
}

final class PropertyInspectorViewController: ElementInspectorPanelViewController {
    
    func calculatePreferredContentSize() -> CGSize {
        viewCode.contentView.systemLayoutSizeFitting(
            CGSize(
                width: min(UIScreen.main.bounds.width, 414),
                height: 0
            ),
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    // MARK: - Properties
    
    weak var delegate: PropertyInspectorViewControllerDelegate?
    
    private var viewModel: PropertyInspectorViewModelProtocol!
    
    var selectedColorPicker: ColorPicker?
    
    var selectedOptionSelector: OptionSelector?
    
    private lazy var viewCode = PropertyInspectorViewCode()
    
    private var needsSetup = true
    
    private(set) lazy var snapshotViewCode = PropertyInspectorViewThumbnailSectionView(
        reference: viewModel.reference,
        frame: .zero
    ).then {
        $0.toggleHighlightViewsControl.isOn = !viewModel.reference.isHidingHighlightViews
        $0.toggleHighlightViewsControl.addTarget(self, action: #selector(toggleLayerInspectorViewsVisibility), for: .valueChanged)
    }
    
    private(set) lazy var sectionViews: [PropertyInspectorSectionView] = {
        viewModel.sectionInputs.enumerated().map { index, section in
            PropertyInspectorSectionView(
                section: section,
                isCollapsed: index > 0
            ).then {
                $0.delegate = self
            }
        }
    }()
    
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
        
        sectionViews.forEach { viewCode.contentView.addArrangedSubview($0) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        snapshotViewCode.startLiveUpdatingSnaphost()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        needsSetup = true
        
        snapshotViewCode.stopLiveUpdatingSnaphost()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        guard parent == nil else {
            return
        }
        
        snapshotViewCode.stopLiveUpdatingSnaphost()
    }
    
    deinit {
        snapshotViewCode.stopLiveUpdatingSnaphost()
    }
}

// MARK: - API

extension PropertyInspectorViewController {
    
    func selectColor(_ color: UIColor) {
        selectedColorPicker?.selectedColor = color
    }
    
    func finishColorSelection() {
        selectedColorPicker = nil
    }
    
    func selectOptionAtIndex(_ index: Int?) {
        selectedOptionSelector?.selectedIndex = index
    }
    
    func finishOptionSelction() {
        selectedOptionSelector = nil
    }
    
}

// MARK: - Actions

private extension PropertyInspectorViewController {
    
    @objc func toggleLayerInspectorViewsVisibility() {
        DispatchQueue.main.async { [weak self] in
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
    }
    
}
