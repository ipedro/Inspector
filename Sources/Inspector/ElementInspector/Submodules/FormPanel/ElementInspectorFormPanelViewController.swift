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
                                   didUpdateProperty property: InspectorElementProperty,
                                   in section: InspectorElementSection)
}

protocol ElementInspectorFormPanelItemStateDelegate: AnyObject {
    func elementInspectorFormPanelItemDidChangeState(_ formPanelViewController: ElementInspectorFormPanelViewController)
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

    weak var itemStateDelegate: ElementInspectorFormPanelItemStateDelegate?

    weak var formDelegate: ElementInspectorFormPanelDelegate?

    var dataSource: ElementInspectorFormPanelDataSource? {
        didSet {
            if isViewLoaded {
                reloadData()
            }
        }
    }

    var selectedColorPreviewControl: ColorPreviewControl?

    var selectedImagePreviewControl: ImagePreviewControl?

    var selectedOptionListControl: OptionListControl?

    private(set) var sections: [InspectorElementSectionViewController: InspectorElementSection] = [:]

    var formPanels: [InspectorElementSectionViewController] {
        children.compactMap { $0 as? InspectorElementSectionViewController }
    }

    var containsExpandedFormItem: Bool { collapseState != .allCollapsed }

    var collapseState: ElementInspectorPanelListState {
        let expandedItems = formPanels.filter { $0.state == .expanded }

        guard expandedItems.isEmpty == false else { return .allCollapsed }

        guard expandedItems.count < formPanels.count else { return .allExpanded }

        if expandedItems.first?.state == .expanded { return .firstExpanded }

        return .mixed
    }

    var panelSelectionMode: ElementInspectorPanelSelectionMode {
        if isFullHeightPresentation {
            return .multipleSelection
        }
        else {
            return .singleSelection
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
}

// MARK: - DataReloadingProtocol

extension ElementInspectorFormPanelViewController: DataReloadingProtocol {
    func reloadData() {
        viewCode.contentView.removeAllArrangedSubviews()

        children.forEach { child in
            child.view.removeFromSuperview()
            child.willMove(toParent: nil)
            child.removeFromParent()
        }

        guard let dataSource = dataSource else { return }

        for sectionIndex in 0 ..< dataSource.numberOfSections {
            let section = dataSource.section(at: sectionIndex)

            if let title = section.title {
                viewCode.contentView.addArrangedSubview(
                    sectionHeader(title: title)
                )
            }

            for (row, item) in section.rows.enumerated() {
                item.state = row + sectionIndex == .zero ? .expanded : .collapsed

                let view = item.makeView().then {
                    $0.separatorStyle = .bottom
                }

                let sectionViewController = InspectorElementSectionViewController(view: view).then {
                    $0.dataSource = item
                    $0.delegate = self
                }

                addChild(sectionViewController)

                sectionViewController.viewWillAppear(false)

                viewCode.contentView.addArrangedSubview(view)

                sectionViewController.didMove(toParent: self)

                sections[sectionViewController] = section
            }
        }
    }

    private func sectionHeader(title: String) -> SectionHeader {
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
    }
}

extension ElementInspectorFormPanelViewController {
    func togglePanels(to newState: ElementInspectorPanelListState, animated: Bool, completion: ((Bool) -> Void)? = nil) {
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
    private func apply(state: ElementInspectorPanelListState?) -> Bool {
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

    func willUpdate(property: InspectorElementProperty) {}

    func didUpdate(property: InspectorElementProperty) {}
}
