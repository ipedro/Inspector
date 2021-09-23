//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
        $0.pickerView.delegate = self

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

    convenience init(viewModel: OptionSelectorViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
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

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let title = viewModel.title(for: row, in: component) else {
            return SeparatorView(style: .color(Inspector.configuration.colorStyle.textColor))
        }

        return SectionHeader(title: title, titleFont: .callout)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 50 }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case .zero:
            delegate?.optionSelectorViewController(self, didSelectIndex: row)

        default:
            break
        }
    }
}
