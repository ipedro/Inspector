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
}

final class PropertyInspectorViewController: UIViewController {
    weak var delegate: PropertyInspectorViewControllerDelegate?
    
    private var viewModel: PropertyInspectorViewModelProtocol!
    
    private var presentedColorPicker: ColorPicker?
    
    private lazy var viewCode = PropertyInspectorViewCode().then { viewCode in
        sections.forEach { section in
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
        presentedColorPicker?.selectedColor = color
    }
    
    func finishColorSelection() {
        presentedColorPicker = nil
    }
}

extension PropertyInspectorViewController: PropertyInspectorSectionDelegate {
    func propertyInspectorSection(_ section: PropertyInspectorSection, didTapColorPicker
                                    colorPicker: ColorPicker,
                                  sourceRect: CGRect) {
        presentedColorPicker = colorPicker
        delegate?.propertyInspectorViewController(
            self,
            didTapColorPicker: colorPicker,
            sourceRect: sourceRect
        )
    }
}
