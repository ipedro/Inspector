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

protocol ElementInspectorFormPanelDelegate: OperationQueueManagerProtocol {
    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap colorPicker: ColorPreviewControl)

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap imagePicker: ImagePreviewControl)

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap optionSelector: OptionListControl)

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didUpdateProperty: InspectorElementViewModelProperty,
                                   in item: ElementInspectorFormItem)
}

class ElementInspectorFormPanelViewController: ElementInspectorPanelViewController {
    func addOperationToQueue(_ operation: MainThreadOperation) {
        formDelegate?.addOperationToQueue(operation)
    }

    func suspendQueue(_ isSuspended: Bool) {
        formDelegate?.suspendQueue(isSuspended)
    }

    func cancelAllOperations() {
        formDelegate?.cancelAllOperations()
    }

    func elementInspectorFormItemViewController(
        _ formItemController: ElementInspectorFormItemViewController,
        willChangeFrom oldState: InspectorElementFormItemState?,
        to newState: InspectorElementFormItemState
    ) {
        animatePanel { [weak self] in
            formItemController.state = newState

            guard let self = self else { return }

            switch newState {
            case .expanded:
                for aFormItemController in self.formItemViewControllers where aFormItemController !== formItemController {
                    aFormItemController.state = .collapsed
                }

            case .collapsed:
                break
            }
        }
    }

    weak var formDelegate: ElementInspectorFormPanelDelegate?

    var dataSource: ElementInspectorFormPanelDataSource {
        didSet {
            reloadData()
        }
    }

    var selectedColorPicker: ColorPreviewControl?

    var selectedImagePicker: ImagePreviewControl?

    var selectedOptionSelector: OptionListControl?

    private var itemsDictionary: [ElementInspectorFormItemViewController: ElementInspectorFormItem] = [:]

    var formItemViewControllers: [ElementInspectorFormItemViewController] {
        children.compactMap { $0 as? ElementInspectorFormItemViewController }
    }

    var isCompactVerticalPresentation: Bool! {
        didSet {
            let formItemViewControllers = formItemViewControllers

            if isCompactVerticalPresentation {
                formItemViewControllers.forEach { $0.state = .collapsed }
                return
            }

            if formItemViewControllers.first(where: { $0.state == .expanded }) == nil {
                formItemViewControllers.first?.state = .expanded
            }
        }
    }

    private lazy var viewCode = BaseView()

    // MARK: - Init

    init(dataSource: ElementInspectorFormPanelDataSource) {
        self.dataSource = dataSource

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        guard let parent = parent else { return }

        isCompactVerticalPresentation = {
            if let popover = parent.popoverPresentationController {
                #if swift(>=5.5)
                if #available(iOS 15.0, *) {
                    return popover.adaptiveSheetPresentationController.selectedDetentIdentifier != .large
                }
                #endif

                return true
            }

            return false
        }()
    }

    func reloadData() {
        viewCode.contentView.removeAllArrangedSubviews()

        dataSource.items.enumerated().forEach { section, item in
            if let title = item.title {
                self.viewCode.contentView.addArrangedSubview(
                    SectionHeader(
                        title: title,
                        titleFont: .init(.headline, .traitBold),
                        margins: .init(
                            top: ElementInspector.appearance.horizontalMargins,
                            leading: ElementInspector.appearance.horizontalMargins + ElementInspector.appearance.verticalMargins + 24,
                            bottom: ElementInspector.appearance.horizontalMargins,
                            trailing: ElementInspector.appearance.horizontalMargins + ElementInspector.appearance.verticalMargins
                        )
                    ).then {
                        $0.alpha = 0.5
                    }
                )
            }

            for (row, viewModel) in item.rows.enumerated() {
                let indexPath = IndexPath(row: row, section: section)

                let ItemType = dataSource.typeForRow(at: indexPath)

                let itemView = ItemType.makeItemView().then {
                    $0.separatorStyle = indexPath.isFirst ? .none : .top
                }

                let formItemViewController = ElementInspectorFormItemViewController(
                    viewModel: viewModel,
                    viewCode: itemView,
                    state: {
                        if isCompactVerticalPresentation == false, indexPath.isFirst {
                            return .expanded
                        }
                        return .collapsed
                    }()
                ).then {
                    $0.delegate = self
                }

                addChild(formItemViewController)

                formItemViewController.viewWillAppear(false)

                self.viewCode.contentView.addArrangedSubview(itemView)

                itemView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true

                formItemViewController.didMove(toParent: self)

                self.itemsDictionary[formItemViewController] = item
            }
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

    func willUpdate(property: InspectorElementViewModelProperty) {}

    func didUpdate(property: InspectorElementViewModelProperty) {}
}

// MARK: - ElementInspectorFormItemViewControllerDelegate

extension ElementInspectorFormPanelViewController: ElementInspectorFormItemViewControllerDelegate {
    func elementInspectorFormItemViewController(
        _ formItemController: ElementInspectorFormItemViewController,
        willUpdate property: InspectorElementViewModelProperty
    ) {
        willUpdate(property: property)
    }

    func elementInspectorFormItemViewController(
        _ formItemController: ElementInspectorFormItemViewController,
        didUpdate property: InspectorElementViewModelProperty
    ) {
        let updateOperation = MainThreadOperation(name: "update sections") { [weak self] in
            guard
                let self = self,
                let item = self.itemsDictionary[formItemController]
            else {
                return
            }

            self.formItemViewControllers.forEach { $0.reloadData() }

            self.didUpdate(property: property)

            self.formDelegate?.elementInspectorFormPanel(self, didUpdateProperty: property, in: item)
        }

        formDelegate?.addOperationToQueue(updateOperation)
    }

    func elementInspectorFormItemViewController(
        _ formItemController: ElementInspectorFormItemViewController,
        didChangeState newState: UIControl.State,
        from oldState: UIControl.State
    ) {
        animatePanel(
            animations: { [weak self] in
                guard let self = self else { return }

                let selectedSections: [ElementInspectorFormItemViewController] = self.children
                    .compactMap { $0 as? ElementInspectorFormItemViewController }
                    .filter { $0.state == .expanded }

                for section in selectedSections {
                    section.state = .collapsed
                }

                formItemController.state = .expanded
            },
            completion: nil
        )
    }

    func elementInspectorFormItemViewController(
        _ formItemController: ElementInspectorFormItemViewController,
        didTap imagePicker: ImagePreviewControl
    ) {
        selectedImagePicker = imagePicker
        formDelegate?.elementInspectorFormPanel(self, didTap: imagePicker)
    }

    func elementInspectorFormItemViewController(
        _ formItemController: ElementInspectorFormItemViewController,
        didTap colorPicker: ColorPreviewControl
    ) {
        selectedColorPicker = colorPicker
        formDelegate?.elementInspectorFormPanel(self, didTap: colorPicker)
    }

    func elementInspectorFormItemViewController(
        _ formItemController: ElementInspectorFormItemViewController,
        didTap optionSelector: OptionListControl
    ) {
        selectedOptionSelector = optionSelector
        formDelegate?.elementInspectorFormPanel(self, didTap: optionSelector)
    }
}

private extension IndexPath {
    var isFirst: Bool {
        row == .zero && section == .zero
    }
}
