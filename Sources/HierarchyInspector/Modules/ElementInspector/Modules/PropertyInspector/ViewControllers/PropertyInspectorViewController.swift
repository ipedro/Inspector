//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewControllerDelegate: AnyObject {
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTapColorPicker colorPicker: ColorPicker)
}

final class PropertyInspectorViewController: UIViewController {
    weak var delegate: PropertyInspectorViewControllerDelegate?
    
    private var viewModel: PropertyInspectorViewModelProtocol!
    
    private var presentedColorPicker: ColorPicker?
    
    private lazy var viewCode = PropertyInspectorViewCode().then {
        $0.contentView.addArrangedSubview(viewPanel)
    }
    
    private lazy var viewPanel = PropertyInspectorSection(
        title: "View",
        properties: viewModel.inputs
    ).then {
        $0.delegate = self
    }
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = viewCode.scrollView.contentSize
    }
    
    static func create(viewModel: PropertyInspectorViewModelProtocol) -> PropertyInspectorViewController {
        let viewController = PropertyInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
}

extension PropertyInspectorViewController: PropertyInspectorSectionDelegate {
    func propertyInspectorSection(_ section: PropertyInspectorSection, didTapColorPicker colorPicker: ColorPicker, sourceRect: CGRect) {
        delegate?.propertyInspectorViewController(self, didTapColorPicker: colorPicker)
        if #available(iOS 14.0, *) {
            presentedColorPicker = colorPicker
            
            #warning("move to coordinator")
            let colorPicker = UIColorPickerViewController().then {
                $0.delegate = self
                $0.selectedColor = colorPicker.selectedColor
                $0.modalPresentationStyle = .popover
                $0.popoverPresentationController?.sourceView = view.window
                $0.popoverPresentationController?.sourceRect = sourceRect
            }
            
            present(colorPicker, animated: true)
        }
    }
}

@available(iOS 14.0, *)
extension PropertyInspectorViewController: UIColorPickerViewControllerDelegate {
    #warning("move to coordinator")
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        presentedColorPicker?.selectedColor = viewController.selectedColor
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        presentedColorPicker = nil
    }
}
