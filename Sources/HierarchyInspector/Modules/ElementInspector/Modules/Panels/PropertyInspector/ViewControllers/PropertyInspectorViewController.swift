//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewControllerDelegate: AnyObject {
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         didTap colorPicker: ColorPicker)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         didTap optionSelector: OptionSelector)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         showLayerInspectorViewsInside reference: ViewHierarchyReference)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         hideLayerInspectorViewsInside reference: ViewHierarchyReference)
}

final class PropertyInspectorViewController: UIViewController {
    // MARK: - Properties
    
    weak var delegate: PropertyInspectorViewControllerDelegate?
    
    private var viewModel: PropertyInspectorViewModelProtocol!
    
    private var selectedColorPicker: ColorPicker?
    
    private var selectedOptionSelector: OptionSelector?
    
    private lazy var viewCode = PropertyInspectorViewCode().then {
        $0.scrollView.delegate = self
    }
    
    private lazy var snapshotViewCode = PropertyInspectorViewThumbnailSectionView(
        reference: viewModel.reference,
        frame: CGRect(
            origin: .zero,
            size: CGSize(
                width: viewCode.frame.width,
                height: viewCode.frame.width
            )
        )
    ).then {
        $0.toggleHighlightViewsControl.isOn = !viewModel.reference.isHidingHighlightViews
        $0.toggleHighlightViewsControl.addTarget(self, action: #selector(toggleLayerInspectorViewsVisibility), for: .valueChanged)
    }
    
    private lazy var sectionViews: [PropertyInspectorSectionView] = {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        calculatePreferredContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        snapshotViewCode.startLiveUpdatingSnaphost()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.snapshotViewCode.startLiveUpdatingSnaphost()
        }
    }
    
    func calculatePreferredContentSize() {
        let size = viewCode.contentView.systemLayoutSizeFitting(
            CGSize(
                width: min(UIScreen.main.bounds.width, 414),
                height: 0
            ),
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .fittingSizeLevel
        )

        preferredContentSize = size
    }
    
    // MARK: - API
    
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
    
    @objc private func toggleLayerInspectorViewsVisibility() {
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

// MARK: - PropertyInspectorSectionViewDelegate

extension PropertyInspectorViewController: PropertyInspectorSectionViewDelegate {
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didUpdate property: PropertyInspectorInput) {
        Console.print(#function, property)
    }
    
    func propertyInspectorSectionViewDidTapHeader(_ section: PropertyInspectorSectionView, isCollapsed: Bool) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
            animations: { [weak self] in
                
                guard isCollapsed else {
                    section.isCollapsed.toggle()
                    return
                }
                
                self?.sectionViews.forEach {
                    if $0 === section {
                        $0.isCollapsed = !isCollapsed
                    }
                    else {
                        $0.isCollapsed = isCollapsed
                    }
                }
                
                
            },
            completion: { [weak self] _ in
                self?.snapshotViewCode.startLiveUpdatingSnaphost()
            }
        )
        
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTap colorPicker: ColorPicker) {
        selectedColorPicker = colorPicker
        
        delegate?.propertyInspectorViewController(self, didTap: colorPicker)
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTap optionSelector: OptionSelector) {
        selectedOptionSelector = optionSelector
        
        delegate?.propertyInspectorViewController(self, didTap: optionSelector)
    }
}

extension PropertyInspectorViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapshotViewCode.startLiveUpdatingSnaphost()
    }
}