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

extension ElementInspectorFormPanelViewController: InspectorElementSectionViewControllerDelegate {
    func inspectorElementSectionViewController(_ sectionViewController: InspectorElementSectionViewController,
                                               willUpdate property: InspectorElementProperty) {}

    func inspectorElementSectionViewController(_ sectionViewController: InspectorElementSectionViewController,
                                               didUpdate property: InspectorElementProperty)
    {
        let updateOperation = MainThreadOperation(name: "update sections") { [weak self] in
            guard
                let self = self,
                let item = self.sections[sectionViewController]
            else {
                return
            }

            self.formPanels.forEach { $0.reloadData() }

            self.formDelegate?.elementInspectorFormPanel(self, didUpdateProperty: property, in: item)
        }

        formDelegate?.addOperationToQueue(updateOperation)
    }

    func inspectorElementSectionViewController(_ sectionViewController: InspectorElementSectionViewController,
                                               willChangeFrom oldState: InspectorElementSectionState?,
                                               to newState: InspectorElementSectionState)
    {
        sectionViewController.setState(newState, animated: true)

        switch newState {
        case .expanded where panelSelectionMode == .singleSelection:
            for aFormItemController in formPanels where aFormItemController !== sectionViewController {
                aFormItemController.setState(.collapsed, animated: true)
            }

        case .expanded, .collapsed:
            break
        }

        itemStateDelegate?.elementInspectorFormPanelItemDidChangeState(self)
    }

    func inspectorElementSectionViewController(_ sectionViewController: InspectorElementSectionViewController,
                                               didTap imagePreviewControl: ImagePreviewControl)
    {
        selectedImagePreviewControl = imagePreviewControl
        formDelegate?.elementInspectorFormPanel(self, didTap: imagePreviewControl)
    }

    func inspectorElementSectionViewController(_ sectionViewController: InspectorElementSectionViewController,
                                               didTap colorPreviewControl: ColorPreviewControl)
    {
        selectedColorPreviewControl = colorPreviewControl
        formDelegate?.elementInspectorFormPanel(self, didTap: colorPreviewControl)
    }
}
