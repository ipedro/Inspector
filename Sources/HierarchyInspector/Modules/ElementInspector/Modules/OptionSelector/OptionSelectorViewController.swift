//
//  OptionSelectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

protocol OptionSelectorViewControllerDelegate: AnyObject {
    func optionSelectorViewController(_ viewController: OptionSelectorViewController, didSelectIndex selectedIndex: Int?)
}

final class OptionSelectorViewController: UIViewController {
    weak var delegate: OptionSelectorViewControllerDelegate?
    
    private var viewModel: OptionSelectorViewModelProtocol! {
        didSet {
            guard let selectedRow = viewModel.selectedRow else {
                return
            }
            
            viewCode.pickerView.reloadAllComponents()
            
            viewCode.pickerView.selectRow(selectedRow.row, inComponent: selectedRow.component, animated: false)
            
        }
    }
    
    private lazy var viewCode = OptionSelectorViewCode().then {
        $0.pickerView.dataSource = self
        $0.pickerView.delegate   = self
        
        $0.dismissBarButtonItem.action = #selector(close)
        $0.dismissBarButtonItem.target = self
    }
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        
        preferredContentSize = CGSize(width: 280, height: 260)
    }
    
    static func create(viewModel: OptionSelectorViewModelProtocol) -> OptionSelectorViewController {
        let viewController = OptionSelectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}

extension OptionSelectorViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        viewModel.numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.numberOfRows(in: component)
    }
}

extension OptionSelectorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.title(for: row, in: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case .zero:
            delegate?.optionSelectorViewController(self, didSelectIndex: row)
            
        default:
            break
        }
    }
}
