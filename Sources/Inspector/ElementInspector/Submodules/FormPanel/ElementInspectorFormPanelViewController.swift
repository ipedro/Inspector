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

protocol ElementInspectorFormPanelItemStateDelegate: AnyObject {
    func elementInspectorFormPanelItemDidChangeState(_ formPanelViewController: ElementInspectorFormPanelViewController)
}

enum ElementInspectorFormPanelCollapseState: Swift.CaseIterable, MenuContentProtocol {
    case allCollapsed, firstExpanded, mixed, allExpanded

    func next() -> Self {
        switch self {
        case .allCollapsed:
            return .firstExpanded
        case .firstExpanded:
            return .allExpanded
        case .mixed:
            return .allExpanded
        case .allExpanded:
            return .allCollapsed
        }
    }

    // MARK: - MenuContentProtocol

    static func allCases(for element: ViewHierarchyElement) -> [ElementInspectorFormPanelCollapseState] { [] }

    var title: String {
        switch self {
        case .allCollapsed:
            return "Collapse All"
        case .firstExpanded:
            return "Expand First"
        case .mixed:
            return "Mixed selection"
        case .allExpanded:
            return "Expand All"
        }
    }

    var image: UIImage? {
        switch self {
        case .allCollapsed:
            return .collapseSymbol
        case .firstExpanded:
            return .expandSymbol
        case .mixed:
            return nil
        case .allExpanded:
            return .expandSymbol
        }
    }
}

enum ElementInspectorFormPanelSelectionMode: Swift.CaseIterable {
    case single, multi
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

    weak var itemStateDelegate: ElementInspectorFormPanelItemStateDelegate?

    weak var formDelegate: ElementInspectorFormPanelDelegate?

    var dataSource: ElementInspectorFormPanelDataSource? {
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

    var containsExpandedFormItem: Bool { collapseState != .allCollapsed }

    var collapseState: ElementInspectorFormPanelCollapseState {
        let expandedItems = formItemViewControllers.filter { $0.state == .expanded }

        guard expandedItems.isEmpty == false else { return .allCollapsed }

        guard expandedItems.count < formItemViewControllers.count else { return .allExpanded }

        if expandedItems.first?.state == .expanded { return .firstExpanded }

        return .mixed
    }

    var panelSelectionMode: ElementInspectorFormPanelSelectionMode {
        if isFullHeightPresentation {
            return .multi
        }
        else {
            return .single
        }
    }

    override var isFullHeightPresentation: Bool {
        didSet {
            guard oldValue != isFullHeightPresentation else { return }

            let isExpanding = !oldValue && isFullHeightPresentation

            animatePanel {
                if isExpanding {
                    self.didVerticallyExpandPresentation()
                }
                else {
                    self.didVerticallyCompressPresentation()
                }
            }
        }
    }

    private func didVerticallyCompressPresentation() {
        switch collapseState {
        case .firstExpanded:
            break

        case .allExpanded:
            return expandFirstSection()

        case .allCollapsed:
            break

        case .mixed:
            break
        }
    }

    private func didVerticallyExpandPresentation() {
        switch collapseState {
        case .firstExpanded:
            return expandAllSections()

        case .allExpanded:
            break

        case .allCollapsed:
            return expandFirstSection()

        case .mixed:
            break
        }
    }

    private lazy var viewCode = BaseView()

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }

    // MARK: - Internal API

    func reloadData() {
        viewCode.contentView.removeAllArrangedSubviews()

        guard let dataSource = dataSource else { return }

        dataSource.items.enumerated().forEach { section, item in
            if let title = item.title {
                self.viewCode.contentView.addArrangedSubview(
                    SectionHeader(
                        title: title,
                        titleFont: .title3,
                        margins: ElementInspector.appearance.directionalInsets.with(
                            top: ElementInspector.appearance.horizontalMargins * 2,
                            bottom: ElementInspector.appearance.horizontalMargins * 2
                        )
                    ).then {
                        $0.alpha = 0.5
                    }
                )
            }

            for (row, viewModel) in item.rows.enumerated() {
                let indexPath = IndexPath(row: row, section: section)

                let itemView = dataSource.viewForProperty(at: indexPath).then {
                    $0.separatorStyle = .bottom
                }

                let formItemViewController = ElementInspectorFormItemViewController(
                    viewModel: viewModel,
                    viewCode: itemView
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
}

extension ElementInspectorFormPanelViewController {
    func toggleAllSectionsCollapse(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard animated else {
            advanceCollapseState()
            itemStateDelegate?.elementInspectorFormPanelItemDidChangeState(self)
            return
        }

        animatePanel {
            self.advanceCollapseState()

        } completion: { [weak self] finished in
            completion?(finished)

            if let self = self {
                self.itemStateDelegate?.elementInspectorFormPanelItemDidChangeState(self)
            }
        }
    }

    private func advanceCollapseState() {
        switch collapseState.next() {
        case .allCollapsed:
            collapseAllSections()
        case .firstExpanded:
            expandFirstSection()
        case .mixed:
            break
        case .allExpanded:
            expandAllSections()
        }
    }

    private func collapseAllSections() {
        formItemViewControllers.forEach { $0.state = .collapsed }
    }

    private func expandFirstSection() {
        fatalError("not working for some reason")

        (wip)

        collapseAllSections()
        formItemViewControllers.first?.state = .expanded
    }

    private func expandAllSections() {
        formItemViewControllers.forEach { $0.state = .expanded }
    }
}

// MARK: - Selection

extension ElementInspectorFormPanelViewController {
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
            case .expanded where self.panelSelectionMode == .single:
                for aFormItemController in self.formItemViewControllers where aFormItemController !== formItemController {
                    aFormItemController.state = .collapsed
                }

            case .expanded, .collapsed:
                break
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.itemStateDelegate?.elementInspectorFormPanelItemDidChangeState(self)
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
