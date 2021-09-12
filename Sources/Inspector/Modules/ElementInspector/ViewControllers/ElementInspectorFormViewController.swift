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

@_implementationOnly import UIKeyboardAnimatable
import UIKit

protocol ElementInspectorFormViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        didTap colorPicker: ColorPreviewControl)

    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        didTap imagePicker: ImagePreviewControl)

    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        didTap optionSelector: OptionListControl)

    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        showLayerInspectorViewsInside reference: ViewHierarchyReference)

    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        hideLayerInspectorViewsInside reference: ViewHierarchyReference)
}

protocol ElementInspectorFormViewControllerDataSource: AnyObject {
    typealias Section = [ElementInspectorFormViewModelProtocol]
    typealias Title = String

    var sections: [Title: Section] { get }
}

protocol ElementInspectorBaseViewControllerProtocol {
    var sectionViewType: ElementInspectorFormSectionView.Type { get }
    var viewCode: ElementInspectorFormView { get }
}

typealias ElementInspectorFormViewController = ElementInspectorBaseFormViewController & ElementInspectorBaseViewControllerProtocol & ElementInspectorFormSectionViewDelegate

class ElementInspectorBaseFormViewController: ElementInspectorPanelViewController, ElementInspectorFormSectionViewControllerDelegate, KeyboardAnimatable {
    weak var formDelegate: ElementInspectorFormViewControllerDelegate?

    weak var dataSource: ElementInspectorFormViewControllerDataSource?

    var selectedColorPicker: ColorPreviewControl?

    var selectedImagePicker: ImagePreviewControl?

    var selectedOptionSelector: OptionListControl?

    override func loadView() {
        view = (self as? ElementInspectorFormViewController)?.viewCode ?? UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let self = self as? ElementInspectorFormViewController else { return }

        loadSections()

        animateWhenKeyboard(.willChangeFrame) { info in
            self.viewCode.keyboardHeight = info.keyboardFrame.height
            self.viewCode.layoutIfNeeded()
        }
    }

    func loadSections() {
        guard let self = self as? ElementInspectorFormViewController else { return }

        dataSource?.sections.forEach { section in
            let sectionHeaderView = SectionHeader(
                .headline,
                text: section.key,
                margins: .init(insets: ElementInspector.appearance.horizontalMargins)
            ).then {
                $0.alpha = 0.5
            }

            self.viewCode.contentView.addArrangedSubview(sectionHeaderView)

            for (index, viewModel) in section.value.enumerated() {
                let sectionViewController = ElementInspectorFormSectionViewController.create(
                    viewModel: viewModel,
                    viewCode: self.sectionViewType.init()
                ).then {
                    $0.isCollapsed = index > 0
                    $0.delegate = self
                }

                addChild(sectionViewController)

                self.viewCode.contentView.addArrangedSubview(sectionViewController.view)

                sectionViewController.didMove(toParent: self)
            }
        }
    }

    func calculatePreferredContentSize() -> CGSize {
        if isViewLoaded {
            return view.systemLayoutSizeFitting(
                ElementInspector.appearance.panelPreferredCompressedSize,
                withHorizontalFittingPriority: .defaultHigh,
                verticalFittingPriority: .fittingSizeLevel
            )
        }
        else {
            return .zero
        }
    }

    func selectImage(_ image: UIImage?) {
        selectedImagePicker?.updateSelectedImage(image)
    }

    func selectColor(_ color: UIColor) {
        selectedColorPicker?.updateSelectedColor(color)
    }

    func selectOptionAtIndex(_ index: Int?) {
        selectedOptionSelector?.updateSelectedIndex(index)
    }

    func finishColorSelection() {
        selectedColorPicker = nil
    }

    func finishOptionSelction() {
        selectedOptionSelector = nil
    }

    func animatePanel(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration * 2,
            delay: 0.05,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
            animations: animations,
            completion: completion
        )
    }

    // MARK: - ElementInspectorFormSectionViewControllerDelegate

    func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController, willUpdate property: InspectorElementViewModelProperty) {}

    func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController, didUpdate property: InspectorElementViewModelProperty) {}

    func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController, didToggle isCollapsed: Bool) {
        animatePanel(
            animations: { [weak self] in
                guard let self = self else { return }

                viewController.isCollapsed.toggle()

                let sectionViewControllers = self.children.compactMap { $0 as? ElementInspectorFormSectionViewController }

                for sectionViewController in sectionViewControllers where sectionViewController !== viewController {
                    sectionViewController.isCollapsed = true
                }
            },
            completion: nil
        )
    }

    func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController,
                                                   didTap imagePicker: ImagePreviewControl)
    {
        selectedImagePicker = imagePicker

        guard let self = self as? ElementInspectorFormViewController else { return }

        self.formDelegate?.elementInspectorViewController(self, didTap: imagePicker)
    }

    func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController,
                                                   didTap colorPicker: ColorPreviewControl)
    {
        selectedColorPicker = colorPicker

        guard let self = self as? ElementInspectorFormViewController else { return }

        self.formDelegate?.elementInspectorViewController(self, didTap: colorPicker)
    }

    func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController,
                                                   didTap optionSelector: OptionListControl)
    {
        selectedOptionSelector = optionSelector

        guard let self = self as? ElementInspectorFormViewController else { return }

        self.formDelegate?.elementInspectorViewController(self, didTap: optionSelector)
    }
}

// MARK: - OperationQueueManagerProtocol

extension ElementInspectorBaseFormViewController: OperationQueueManagerProtocol {
    func cancelAllOperations() {
        formDelegate?.cancelAllOperations()
    }

    func suspendQueue(_ isSuspended: Bool) {
        formDelegate?.suspendQueue(isSuspended)
    }

    func addOperationToQueue(_ operation: MainThreadOperation) {
        formDelegate?.addOperationToQueue(operation)
    }
}
