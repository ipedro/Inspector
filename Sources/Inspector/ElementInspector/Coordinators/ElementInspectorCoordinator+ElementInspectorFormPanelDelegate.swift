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
    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didUpdateProperty property: InspectorElementProperty,
                                   in section: InspectorElementSection)
    {
        guard let elementInspectorViewController = formPanelViewController.parent as? ElementInspectorViewController else {
            assertionFailure("whaaaat")
            return
        }

        elementInspectorViewController.reloadData()

        elementInspectorViewController.viewModel.element.highlightView?.reloadData()
    }

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController, didTap colorPreviewControl: ColorPreviewControl) {
        if #available(iOS 14.0, *) {
            let colorPickerViewController = UIColorPickerViewController().then {
                $0.delegate = colorPicker

                if let selectedColor = colorPreviewControl.selectedColor {
                    $0.selectedColor = selectedColor
                }

                #if swift(>=5.5)
                if #available(iOS 15.0, *),
                   let sheet = $0.sheetPresentationController
                {
                    sheet.detents = [.medium(), .large()]
                    sheet.selectedDetentIdentifier = .medium
                    sheet.prefersGrabberVisible = true
                    sheet.sourceView = colorPreviewControl
                    sheet.preferredCornerRadius = Inspector.sharedInstance.appearance.elementInspector.horizontalMargins
                }
                #endif
            }

            formPanelViewController.present(colorPickerViewController, animated: true)
        }
    }

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap imagePreviewControl: ImagePreviewControl)
    {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        ).then {
            $0.view.tintColor = $0.colorStyle.textColor
            setPopoverModalPresentationStyle(for: $0, from: imagePreviewControl.accessoryControl)
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
                        .documentPickerDelegate(self.documentPicker),
                        .viewOptions(
                            .tintColor(Inspector.sharedInstance.configuration.colorStyle.textColor)
                        )
                    ).then {
                        self.setPopoverModalPresentationStyle(for: $0, from: imagePreviewControl.accessoryControl)
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
