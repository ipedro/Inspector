//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewControllerDelegate: AnyObject {
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTapColorPicker colorPicker: ColorPicker)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTapOptionSelector optionSelector: OptionSelector)
}

final class PropertyInspectorViewController: UIViewController {
    weak var delegate: PropertyInspectorViewControllerDelegate?
    
    private var viewModel: PropertyInspectorViewModelProtocol!
    
    private var selectedColorPicker: ColorPicker?
    
    private var selectedOptionSelector: OptionSelector?
    
    private lazy var viewCode = PropertyInspectorViewCode()
    
    private lazy var snapshotViewCode: PropertyInspectorViewReferenceSnapshotView? = {
        guard let referenceView = viewModel.reference.view else {
            return nil
        }
        
        return PropertyInspectorViewReferenceSnapshotView(targetView: referenceView)
    }()
    
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
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCode.elementNameLabel.text = viewModel.reference.elementName
        
        viewCode.elementDescriptionLabel.text = viewModel.reference.elementDescription
        
        if let snapshotViewCode = snapshotViewCode {
            viewCode.contentView.addArrangedSubview(snapshotViewCode)
        }
        
        sectionViews.forEach { viewCode.contentView.addArrangedSubview($0) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        calculatePreferredContentSize()
    }
    
    func calculatePreferredContentSize() {
        let size = viewCode.contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)

        preferredContentSize = size
    }
    
    static func create(viewModel: PropertyInspectorViewModelProtocol) -> PropertyInspectorViewController {
        let viewController = PropertyInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
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

extension PropertyInspectorViewController: PropertyInspectorSectionViewDelegate {
    
    func propertyInspectorSectionViewDidTapHeader(_ section: PropertyInspectorSectionView, isCollapsed: Bool) {
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
            completion: nil
        )
        
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTapColorPicker colorPicker: ColorPicker) {
        selectedColorPicker = colorPicker
        
        delegate?.propertyInspectorViewController(self, didTapColorPicker: colorPicker)
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTapOptionSelector optionSelector: OptionSelector) {
        selectedOptionSelector = optionSelector
        
        delegate?.propertyInspectorViewController(self, didTapOptionSelector: optionSelector)
    }
}
