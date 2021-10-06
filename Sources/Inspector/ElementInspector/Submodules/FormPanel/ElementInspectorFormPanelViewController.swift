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

    func next() -> Self? {
        switch self {
        case .allCollapsed:
            return .firstExpanded
        case .mixed, .firstExpanded:
            return .allExpanded
        case .allExpanded:
            return .none
        }
    }

    func previous() -> Self? {
        switch self {
        case .allCollapsed:
            return .none
        case .firstExpanded:
            return .allCollapsed
        case .mixed:
            return .allCollapsed
        case .allExpanded:
            return .firstExpanded
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
            return .collapseMirroredSymbol
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
            if isViewLoaded {
                reloadData()
            }
        }
    }

    private var selectedColorPreviewControl: ColorPreviewControl?

    private var selectedImagePreviewControl: ImagePreviewControl?

    private var selectedOptionListControl: OptionListControl?

    private var itemsDictionary: [ElementInspectorFormItemViewController: ElementInspectorFormItem] = [:]

    private var formPanels: [ElementInspectorFormItemViewController] {
        children.compactMap { $0 as? ElementInspectorFormItemViewController }
    }

    var containsExpandedFormItem: Bool { collapseState != .allCollapsed }

    var collapseState: ElementInspectorFormPanelCollapseState {
        let expandedItems = formPanels.filter { $0.state == .expanded }

        guard expandedItems.isEmpty == false else { return .allCollapsed }

        guard expandedItems.count < formPanels.count else { return .allExpanded }

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
                    self.apply(state: self.collapseState.next())
                }
                else {
                    self.apply(state: self.collapseState.previous())
                }
            }
        }
    }

    private lazy var viewCode = BaseView()

    override func loadView() {
        view = viewCode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
    }

    // MARK: - Internal API

    func reloadData() {
        viewCode.contentView.removeAllArrangedSubviews()

        children.forEach { child in
            child.view.removeFromSuperview()
            child.willMove(toParent: nil)
            child.removeFromParent()
        }

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
    func togglePanels(to newState: ElementInspectorFormPanelCollapseState, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard animated else {
            apply(state: newState)
            itemStateDelegate?.elementInspectorFormPanelItemDidChangeState(self)
            return
        }

        animatePanel {
            self.apply(state: newState)

        } completion: { [weak self] finished in
            completion?(finished)

            if let self = self {
                self.itemStateDelegate?.elementInspectorFormPanelItemDidChangeState(self)
            }
        }
    }

    @discardableResult
    private func apply(state: ElementInspectorFormPanelCollapseState?) -> Bool {
        switch state {
        case .none:
            return false

        case .mixed:
            assertionFailure("should never set mixed state")
            return false

        case .allCollapsed:
            collapseAllSections()

        case .firstExpanded:
            expandFirstSection()

        case .allExpanded:
            expandAllSections()
        }

        return true
    }

    private func collapseAllSections() {
        formPanels.forEach { $0.state = .collapsed }
    }

    private func expandFirstSection() {
        formPanels.enumerated().forEach { index, form in
            form.state = index == .zero ? .expanded : .collapsed
        }
    }

    private func expandAllSections() {
        formPanels.forEach { $0.state = .expanded }
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

            self.formPanels.forEach { $0.reloadData() }

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
                for aFormItemController in self.formPanels where aFormItemController !== formItemController {
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
