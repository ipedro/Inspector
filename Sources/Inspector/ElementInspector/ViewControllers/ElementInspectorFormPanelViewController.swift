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
                                   didTap colorPreviewControl: ColorPreviewControl)

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap imagePreviewControl: ImagePreviewControl)

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didTap optionListControl: OptionListControl)

    func elementInspectorFormPanel(_ formPanelViewController: ElementInspectorFormPanelViewController,
                                   didUpdateProperty: InspectorElementViewModelProperty,
                                   in item: ElementInspectorFormItem)
}

class ElementInspectorFormPanelViewController: ElementInspectorPanelViewController, DataReloadingProtocol {
    func addOperationToQueue(_ operation: MainThreadOperation) {
        formDelegate?.addOperationToQueue(operation)
    }

    func suspendQueue(_ isSuspended: Bool) {
        formDelegate?.suspendQueue(isSuspended)
    }

    func cancelAllOperations() {
        formDelegate?.cancelAllOperations()
    }

    weak var formDelegate: ElementInspectorFormPanelDelegate?

    var dataSource: ElementInspectorFormPanelDataSource {
        didSet {
            reloadData()
        }
    }

    var selectedColorPreviewControl: ColorPreviewControl?

    var selectedImagePreviewControl: ImagePreviewControl?

    var selectedOptionListControl: OptionListControl?

    private var itemsDictionary: [ElementInspectorFormItemViewController: ElementInspectorFormItem] = [:]

    var formItemViewControllers: [ElementInspectorFormItemViewController] {
        children.compactMap { $0 as? ElementInspectorFormItemViewController }
    }

    override var isCompactVerticalPresentation: Bool {
        didSet {
            animatePanel(
                animations: {
                    let formItemViewControllers = self.formItemViewControllers

                    if self.isCompactVerticalPresentation {
                        formItemViewControllers.forEach { $0.state = .collapsed }
                        return
                    }

                    if formItemViewControllers.first(where: { $0.state == .expanded }) == nil {
                        formItemViewControllers.first?.state = .expanded
                    }
                },
                completion: nil
            )
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

                formItemViewController.didMove(toParent: self)

                self.itemsDictionary[formItemViewController] = item
            }
        }
    }

    func selectImage(_ image: UIImage?) {
        selectedImagePreviewControl?.updateSelectedImage(image)
    }

    func selectColor(_ color: UIColor) {
        selectedColorPreviewControl?.updateSelectedColor(color)
    }

    func selectOptionAtIndex(_ index: Int?) {
        selectedOptionListControl?.updateSelectedIndex(index)
    }

    func finishColorSelection() {
        selectedColorPreviewControl = nil
    }

    func finishOptionSelction() {
        selectedOptionListControl = nil
    }

    func animatePanel(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        animate(
            withDuration: .veryLong,
            options: [.beginFromCurrentState, .layoutSubviews],
            animations: animations,
            completion: completion
        )
    }

    func willUpdate(property: InspectorElementViewModelProperty) {}

    func didUpdate(property: InspectorElementViewModelProperty) {}
}

// MARK: - ElementInspectorFormItemViewControllerDelegate

extension ElementInspectorFormPanelViewController: ElementInspectorFormItemViewControllerDelegate {
    func elementInspectorFormItemViewController(_ formItemController: ElementInspectorFormItemViewController,
                                                willUpdate property: InspectorElementViewModelProperty)
{
        willUpdate(property: property)
    }

    func elementInspectorFormItemViewController(_ formItemController: ElementInspectorFormItemViewController,
                                                didUpdate property: InspectorElementViewModelProperty)
    {
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

    func elementInspectorFormItemViewController(_ formItemController: ElementInspectorFormItemViewController,
                                                willChangeFrom oldState: InspectorElementFormItemState?,
                                                to newState: InspectorElementFormItemState)
    {
        animatePanel { [weak self] in
            formItemController.state = newState

            guard let self = self else { return }

            switch newState {
            case .expanded where ElementInspector.configuration.allowsOnlyOneExpandedPanel:
                for aFormItemController in self.formItemViewControllers where aFormItemController !== formItemController {
                    aFormItemController.state = .collapsed
                }

            case .expanded, .collapsed:
                break
            }
        }
    }

    func elementInspectorFormItemViewController(_ formItemController: ElementInspectorFormItemViewController,
                                                didTap imagePreviewControl: ImagePreviewControl)
    {
        selectedImagePreviewControl = imagePreviewControl
        formDelegate?.elementInspectorFormPanel(self, didTap: imagePreviewControl)
    }

    func elementInspectorFormItemViewController(_ formItemController: ElementInspectorFormItemViewController,
                                                didTap colorPreviewControl: ColorPreviewControl)
    {
        selectedColorPreviewControl = colorPreviewControl
        formDelegate?.elementInspectorFormPanel(self, didTap: colorPreviewControl)
    }

    func elementInspectorFormItemViewController(_ formItemController: ElementInspectorFormItemViewController,
                                                didTap optionListControl: OptionListControl)
    {
        selectedOptionListControl = optionListControl
        formDelegate?.elementInspectorFormPanel(self, didTap: optionListControl)
    }
}
