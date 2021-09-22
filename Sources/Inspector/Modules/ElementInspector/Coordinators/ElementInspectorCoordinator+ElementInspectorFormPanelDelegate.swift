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

import MobileCoreServices
import UIKit

extension ElementInspectorCoordinator: ElementInspectorFormPanelDelegate {
    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController, didUpdateProperty: InspectorElementViewModelProperty, in item: ElementInspectorFormItem) {
        guard let elementViewController = formPanelViewController.parent as? ElementInspectorViewController else {
            assertionFailure("whaaaat")
            return
        }

        elementViewController.reloadData()
    }

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController, didTap colorPreviewControl: ColorPreviewControl) {
        if #available(iOS 14.0, *) {
            let colorPickerViewController = UIColorPickerViewController().then {
                $0.setPopoverModalPresentationStyle(delegate: self, from: colorPreviewControl.accessoryControl)
                $0.delegate = self

                if let selectedColor = colorPreviewControl.selectedColor {
                    $0.selectedColor = selectedColor
                }
            }

            formPanelViewController.present(colorPickerViewController, animated: true)
        }
    }

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap optionListControl: OptionListControl)
    {
        let viewModel = OptionSelectorViewModel(
            title: optionListControl.title,
            options: optionListControl.options,
            selectedIndex: optionListControl.selectedIndex
        )

        let optionSelectorViewController = OptionSelectorViewController(viewModel: viewModel).then {
            $0.delegate = self
        }

        let navigationController = makeNavigationController(from: optionListControl.accessoryControl).then {
            $0.viewControllers = [optionSelectorViewController]
            $0.shouldAdaptModalPresentation = false
        }

        formPanelViewController.present(navigationController, animated: true)
    }

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap imagePreviewControl: ImagePreviewControl)
    {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        ).then {
            $0.setPopoverModalPresentationStyle(delegate: self, from: imagePreviewControl.accessoryControl)
            $0.view.tintColor = $0.colorStyle.textColor
        }

        alertController.addAction(
            UIAlertAction(
                title: Texts.cancel,
                style: .cancel,
                handler: nil
            )
        )

        if imagePreviewControl.image != nil {
            alertController.addAction(
                UIAlertAction(
                    title: Texts.clearImage,
                    style: .destructive,
                    handler: { _ in
                        formPanelViewController.selectImage(nil)
                    }
                )
            )
        }

        alertController.addAction(
            UIAlertAction(
                title: Texts.importImage,
                style: .default,
                handler: { [weak self] _ in
                    guard let self = self else {
                        return
                    }

                    let documentPicker = UIDocumentPickerViewController.forImporting(
                        .documentTypes(.image),
                        .asCopy(true),
                        .documentPickerDelegate(self),
                        .viewOptions(
                            .tintColor(Inspector.configuration.colorStyle.textColor)
                        )
                    ).then {
                        $0.setPopoverModalPresentationStyle(delegate: self, from: imagePreviewControl.accessoryControl)
                    }

                    formPanelViewController.present(documentPicker, animated: true)
                }
            )
        )

        formPanelViewController.present(alertController, animated: true) {
            alertController.view.tintColor = formPanelViewController.colorStyle.textColor
        }
    }
}