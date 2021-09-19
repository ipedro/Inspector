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

typealias ElementInspectorFormPanelViewController = ElementInspectorBaseFormPanelViewController & ElementInspectorBaseViewControllerProtocol

protocol ElementInspectorFormPanelViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorFormPanelViewController(
        _ viewController: ElementInspectorFormPanelViewController,
        didTap colorPicker: ColorPreviewControl
    )

    func elementInspectorFormPanelViewController(
        _ viewController: ElementInspectorFormPanelViewController,
        didTap imagePicker: ImagePreviewControl
    )

    func elementInspectorFormPanelViewController(
        _ viewController: ElementInspectorFormPanelViewController,
        didTap optionSelector: OptionListControl
    )

    func elementInspectorFormPanelViewController(
        _ viewController: ElementInspectorFormPanelViewController,
        didUpdateProperty: InspectorElementViewModelProperty,
        in item: ElementInspectorFormItem
    )
}

public struct ElementInspectorFormItem {
    public var title: String?
    public var rows: [InspectorElementViewModelProtocol]

    public init(
        title: String? = nil,
        rows: [InspectorElementViewModelProtocol]
    ) {
        self.title = title
        self.rows = rows
    }
}

public extension Array where Element == ElementInspectorFormItem {
    static func single(_ viewModel: InspectorElementViewModelProtocol) -> Self {
        [.init(rows: [viewModel])]
    }
}

protocol ElementInspectorFormViewControllerDataSource: AnyObject {
    func typeForRow(at indexPath: IndexPath) -> InspectorElementFormItemView.Type?
    var items: [ElementInspectorFormItem] { get }
}

protocol ElementInspectorBaseViewControllerProtocol {
    var viewCode: ElementInspectorFormView { get }
}

class ElementInspectorBaseFormPanelViewController: ElementInspectorPanelViewController, KeyboardAnimatable {
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
        _ sectionController: ElementInspectorFormItemViewController,
        willChangeFrom oldState: InspectorElementFormItemState?,
        to newState: InspectorElementFormItemState
    ) {
        animatePanel { [weak self] in
            sectionController.state = newState

            guard let self = self else { return }

            switch newState {
            case .expanded:
                for aSectionController in self.sectionViewControllers where aSectionController !== sectionController {
                    aSectionController.state = .collapsed
                }

            case .collapsed:
                break
            }
        }
    }

    weak var formDelegate: ElementInspectorFormPanelViewControllerDelegate?

    weak var dataSource: ElementInspectorFormViewControllerDataSource?

    var selectedColorPicker: ColorPreviewControl?

    var selectedImagePicker: ImagePreviewControl?

    var selectedOptionSelector: OptionListControl?

    private var sections: [ElementInspectorFormItemViewController: ElementInspectorFormItem] = [:]

    var sectionViewControllers: [ElementInspectorFormItemViewController] {
        children.compactMap { $0 as? ElementInspectorFormItemViewController }
    }

    override func loadView() {
        view = (self as? ElementInspectorFormPanelViewController)?.viewCode ?? UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let self = self as? ElementInspectorFormPanelViewController else { return }

        reloadData()

        animateWhenKeyboard(.willChangeFrame) { info in
            self.viewCode.keyboardHeight = info.keyboardFrame.height
            self.viewCode.layoutIfNeeded()
        }
    }

    func reloadData() {
        guard let self = self as? ElementInspectorFormPanelViewController else { return }

        self.viewCode.contentView.removeAllArrangedSubviews()

        guard let dataSource = self.dataSource else { return }

        dataSource.items.enumerated().forEach { sectionIndex, item in

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
                let indexPath = IndexPath(row: row, section: sectionIndex)

                let ItemView = dataSource.typeForRow(at: indexPath) ?? ElementInspectorFormItemContentView.self

                let itemView = ItemView.createItemView().then {
                    $0.separatorStyle = indexPath.isFirst ? .none : .top
                }

                let sectionViewController = ElementInspectorFormItemViewController.create(
                    viewModel: viewModel,
                    viewCode: itemView
                ).then {
                    $0.state = indexPath.isFirst ? .expanded : .collapsed
                    $0.delegate = self
                }

                addChild(sectionViewController)

                self.sections[sectionViewController] = item

                self.viewCode.contentView.addArrangedSubview(sectionViewController.view)

                sectionViewController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true

                sectionViewController.didMove(toParent: self)
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

extension ElementInspectorBaseFormPanelViewController: ElementInspectorFormItemViewControllerDelegate {
    func elementInspectorFormItemViewController(
        _ sectionController: ElementInspectorFormItemViewController,
        willUpdate property: InspectorElementViewModelProperty
    ) {
        willUpdate(property: property)
    }

    func elementInspectorFormItemViewController(
        _ sectionController: ElementInspectorFormItemViewController,
        didUpdate property: InspectorElementViewModelProperty
    ) {
        let updateOperation = MainThreadOperation(name: "update sections") { [weak self] in
            guard
                let self = self as? ElementInspectorFormPanelViewController,
                let section = self.sections[sectionController]
            else {
                return
            }

            self.sectionViewControllers.forEach { $0.reloadData() }

            self.didUpdate(property: property)

            self.formDelegate?.elementInspectorFormPanelViewController(self, didUpdateProperty: property, in: section)
        }

        formDelegate?.addOperationToQueue(updateOperation)
    }

    func elementInspectorFormItemViewController(
        _ sectionController: ElementInspectorFormItemViewController,
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

                sectionController.state = .expanded
            },
            completion: nil
        )
    }

    func elementInspectorFormItemViewController(
        _ sectionController: ElementInspectorFormItemViewController,
        didTap imagePicker: ImagePreviewControl
    ) {
        selectedImagePicker = imagePicker

        guard let self = self as? ElementInspectorFormPanelViewController else { return }

        self.formDelegate?.elementInspectorFormPanelViewController(self, didTap: imagePicker)
    }

    func elementInspectorFormItemViewController(
        _ sectionController: ElementInspectorFormItemViewController,
        didTap colorPicker: ColorPreviewControl
    ) {
        selectedColorPicker = colorPicker

        guard let self = self as? ElementInspectorFormPanelViewController else { return }

        self.formDelegate?.elementInspectorFormPanelViewController(self, didTap: colorPicker)
    }

    func elementInspectorFormItemViewController(
        _ sectionController: ElementInspectorFormItemViewController,
        didTap optionSelector: OptionListControl
    ) {
        selectedOptionSelector = optionSelector

        guard let self = self as? ElementInspectorFormPanelViewController else { return }

        self.formDelegate?.elementInspectorFormPanelViewController(self, didTap: optionSelector)
    }
}

private extension IndexPath {
    var isFirst: Bool {
        row == .zero && section == .zero
    }
}
