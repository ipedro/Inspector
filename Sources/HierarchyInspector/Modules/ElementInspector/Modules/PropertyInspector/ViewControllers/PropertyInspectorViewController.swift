//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewControllerDelegate: AnyObject {
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         didTapColorPicker colorPicker: ColorPicker,
                                         sourceRect: CGRect)
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         didTapOptionSelector optionSelector: OptionSelector,
                                         sourceRect: CGRect)
}

final class PropertyInspectorViewController: UIViewController {
    weak var delegate: PropertyInspectorViewControllerDelegate?
    
    private var viewModel: PropertyInspectorViewModelProtocol!
    
    private var selectedColorPicker: ColorPicker?
    
    private var selectedOptionSelector: OptionSelector?
    
    private lazy var viewCode = PropertyInspectorViewCode().then { viewCode in
        sections.enumerated().forEach { index, section in
            viewCode.contentView.addArrangedSubview(section)
        }
    }
    
    private lazy var sections: [PropertyInspectorSection] = {
        let viewPanel = PropertyInspectorSection(
            title: "View",
            properties: viewModel.inputs
        ).then {
            $0.delegate = self
        }
        
        return [viewPanel]
    }()
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calculatePreferredContentSize()
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

extension PropertyInspectorViewController: PropertyInspectorSectionDelegate {
    func propertyInspectorSection(_ section: PropertyInspectorSection, didTapColorPicker colorPicker: ColorPicker, sourceRect: CGRect) {
        selectedColorPicker = colorPicker
        
        delegate?.propertyInspectorViewController(self, didTapColorPicker: colorPicker, sourceRect: sourceRect)
    }
    
    func propertyInspectorSection(_ section: PropertyInspectorSection, didTapOptionSelector optionSelector: OptionSelector, sourceRect: CGRect) {
        selectedOptionSelector = optionSelector
        
        delegate?.propertyInspectorViewController(self, didTapOptionSelector: optionSelector, sourceRect: sourceRect)
    }
}
