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

protocol InspectorElementSectionViewControllerDelegate: OperationQueueManagerProtocol {
    func inspectorElementSectionViewController(
        _ sectionViewController: InspectorElementSectionViewController,
        didTap colorPreviewControl: ColorPreviewControl
    )

    func inspectorElementSectionViewController(
        _ sectionViewController: InspectorElementSectionViewController,
        didTap imagePreviewControl: ImagePreviewControl
    )

    func inspectorElementSectionViewController(
        _ sectionViewController: InspectorElementSectionViewController,
        didUpdateValues: InspectorElementSectionViewController
    )

    func inspectorElementSectionViewController(
        _ sectionViewController: InspectorElementSectionViewController,
        willUpdateValues: InspectorElementSectionViewController
    )

    func inspectorElementSectionViewController(
        _ sectionViewController: InspectorElementSectionViewController,
        willChangeFrom oldState: InspectorElementSectionState?,
        to newState: InspectorElementSectionState
    )
}

final class InspectorElementSectionViewController: UIViewController, DataReloadingProtocol, ElementInspectorAppearanceProviding {
    weak var delegate: InspectorElementSectionViewControllerDelegate?

    let viewCode: InspectorElementSectionView

    weak var dataSource: InspectorElementSectionDataSource? {
        didSet {
            title = dataSource?.title
            viewCode.title = dataSource?.title
            viewCode.subtitle = dataSource?.subtitle
        }
    }

    private var hasAddedFormViews = false

    init(view: InspectorElementSectionView) {
        viewCode = view

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

        viewCode.delegate = self

        guard let dataSource else { return }

        if let titleAccessoryBinding = dataSource.titleAccessoryBinding,
           let titleAccessoryView = titleAccessoryBinding.makeFormView()
        {
            configureDelegates(for: titleAccessoryView)

            if let baseForm = titleAccessoryView as? BaseFormControl {
                baseForm.titleLabel.removeFromSuperview()
            }

            if let control = titleAccessoryView as? UIControl {
                control.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
                control.isEnabled = titleAccessoryBinding.hasHandler
            }

            bindingViews.append((titleAccessoryBinding, titleAccessoryView))
            viewCode.addTitleAccessoryView(titleAccessoryView)
        }

        addFormViewsIfNeeded()
    }

    private func addFormViewsIfNeeded() {
        guard
            state == .expanded,
            hasAddedFormViews == false,
            let delegate,
            let dataSource
        else {
            return
        }

        hasAddedFormViews = true

        let bindings = dataSource.propertyBindings
        for (index, binding) in bindings.enumerated() {
            guard let propertyView = binding.makeFormView() else {
                continue
            }

            let operation = MainThreadAsyncOperation(name: String(index)) { [weak self] in
                guard let self else { return }

                self.configureDelegates(for: propertyView)

                if index == .zero, let sectionHeader = propertyView as? SectionHeader {
                    sectionHeader.margins.top = .zero
                }

                if let control = propertyView as? UIControl {
                    control.addTarget(
                        self,
                        action: #selector(InspectorElementSectionViewController.valueChanged(_:)),
                        for: .valueChanged
                    )
                    control.isEnabled = binding.hasHandler
                }

                if let fromControl = propertyView as? BaseFormControl {
                    let isLastElement = index == bindings.count - 1
                    let nextIsControl = index + 1 < bindings.count
                        ? bindings[index + 1].isControl
                        : false
                    fromControl.isShowingSeparator = (isLastElement || nextIsControl == false) == false
                }

                bindingViews.append((binding, propertyView))

                propertyView.alpha = 0
                viewCode.addFormViews([propertyView])

                animate(withDuration: .veryLong) { propertyView.alpha = 1 }
            }

            delegate.addOperationToQueue(operation)
        }
    }

    func setState(_ state: InspectorElementSectionState, animated: Bool) {
        guard state != viewCode.state else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) {
            self.addFormViewsIfNeeded()
        }

        guard animated else {
            viewCode.state = state
            return
        }

        let itemCount = dataSource?.propertyBindings.count ?? .zero
        let isLargeList = itemCount > 20

        if isLargeList, let formView = viewCode as? InspectorElementSectionFormView {
            formView.collapseIcon.showLoading()
        }

        animate(
            withDuration: .long,
            delay: .veryShort,
            damping: isLargeList ? 0.93 : Animation.defaultDamping
        ) { [weak self] in
            self?.viewCode.state = state

        } completion: { [weak self] _ in
            if let formView = self?.viewCode as? InspectorElementSectionFormView {
                formView.collapseIcon.hideLoading()
            }
        }
    }

    var state: InspectorElementSectionState { viewCode.state }

    private var bindingViews: [(InspectorPropertyBinding, UIView)] = []

    private func configureDelegates(for propertyView: UIView) {
        if let colorPreviewControl = propertyView as? ColorPreviewControl {
            colorPreviewControl.delegate = self
        }

        if let imagePreviewControl = propertyView as? ImagePreviewControl {
            imagePreviewControl.delegate = self
        }

        if let optionListControl = propertyView as? OptionListControl {
            optionListControl.delegate = self
        }
    }
}

// MARK: - Actions

extension InspectorElementSectionViewController {
    @objc private func stateChanged() {
        delegate?.inspectorElementSectionViewController(self, willChangeFrom: .none, to: viewCode.state)
    }

    @objc private func valueChanged(_ sender: AnyObject) {
        for (binding, formView) in bindingViews where formView === sender {
            delegate?.inspectorElementSectionViewController(self, willUpdateValues: self)

            let updateValueOperation = MainThreadOperation(name: "update property value") {
                binding.applyUpdate(from: formView)
            }

            let didUpdateOperation = MainThreadOperation(name: "did update property value") { [weak self] in
                guard let self else { return }

                self.delegate?.inspectorElementSectionViewController(self, didUpdateValues: self)
            }

            didUpdateOperation.addDependency(updateValueOperation)

            delegate?.addOperationToQueue(updateValueOperation)
            delegate?.addOperationToQueue(didUpdateOperation)
            return
        }
    }

    func reloadData() {
        for (binding, formView) in bindingViews {
            binding.reload(formView: formView)
        }
    }
}

// MARK: - ColorPreviewControlDelegate

extension InspectorElementSectionViewController: ColorPreviewControlDelegate {
    func colorPreviewControlDidTap(_ colorPreviewControl: ColorPreviewControl) {
        delegate?.inspectorElementSectionViewController(self, didTap: colorPreviewControl)
    }
}

// MARK: - OptionListControlDelegate

extension InspectorElementSectionViewController: OptionListControlDelegate {
    func optionListControlDidChangeSelectedIndex(_ optionListControl: OptionListControl) {
        valueChanged(optionListControl)
    }
}

// MARK: - ImagePreviewControlDelegate

extension InspectorElementSectionViewController: ImagePreviewControlDelegate {
    func imagePreviewControlDidTap(_ imagePreviewControl: ImagePreviewControl) {
        delegate?.inspectorElementSectionViewController(self, didTap: imagePreviewControl)
    }
}

// MARK: - InspectorElementSectionViewCodeDelegate

extension InspectorElementSectionViewController: InspectorElementFormItemViewDelegate {
    func inspectorElementFormItemView(
        _ item: InspectorElementSectionView,
        willChangeFrom oldState: InspectorElementSectionState?,
        to newState: InspectorElementSectionState
    ) {
        delegate?.inspectorElementSectionViewController(self, willChangeFrom: oldState, to: newState)
    }
}
