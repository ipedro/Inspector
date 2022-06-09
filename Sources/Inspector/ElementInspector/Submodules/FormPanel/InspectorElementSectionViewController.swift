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
        didUpdate property: InspectorElementProperty
    )

    func inspectorElementSectionViewController(
        _ sectionViewController: InspectorElementSectionViewController,
        willUpdate property: InspectorElementProperty
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

        guard let dataSource = dataSource else { return }

        if
            let titleAccessoryProperty = dataSource.titleAccessoryProperty,
            let titleAccessoryView = makeView(for: titleAccessoryProperty)
        {
            if let baseForm = titleAccessoryView as? BaseFormControl {
                baseForm.titleLabel.removeFromSuperview()
            }

            if let control = titleAccessoryView as? UIControl {
                control.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
                control.isEnabled = titleAccessoryProperty.hasHandler
            }

            formViews[titleAccessoryProperty] = titleAccessoryView
            viewCode.addTitleAccessoryView(titleAccessoryView)
        }

        addFormViewsIfNeeded()
    }

    private func addFormViewsIfNeeded() {
        guard
            state == .expanded,
            hasAddedFormViews == false,
            let delegate = delegate,
            let dataSource = dataSource
        else {
            return
        }

        hasAddedFormViews = true

        for (index, property) in dataSource.properties.enumerated() {
            guard let propertyView = makeView(for: property) else { continue }

            let operation = MainThreadAsyncOperation(name: String(index)) { [weak self] in
                guard let self = self else { return }

                if index == .zero, let sectionHeader = propertyView as? SectionHeader {
                    sectionHeader.margins.top = .zero
                }

                if let control = propertyView as? UIControl {
                    control.addTarget(self, action: #selector(InspectorElementSectionViewController.valueChanged(_:)), for: .valueChanged)
                    control.isEnabled = property.hasHandler
                }

                if let fromControl = propertyView as? BaseFormControl {
                    let isLastElement = index == dataSource.properties.count - 1
                    let isNotFollowedByControl = index + 1 < dataSource.properties.count && dataSource.properties[index + 1].isControl == false

                    fromControl.isShowingSeparator = (isLastElement || isNotFollowedByControl) == false
                }

                self.formViews[property] = propertyView

                propertyView.alpha = 0
                self.viewCode.addFormViews([propertyView])

                self.animate(withDuration: .veryLong) { propertyView.alpha = 1 }
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

        let isLargeList = (dataSource?.properties.count ?? .zero) > 20

        if isLargeList, let formView = viewCode as? InspectorElementSectionFormView {
            formView.collapseIcon.showLoading()
        }

        animate(
            withDuration: .veryLong,
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

    private var formViews: [InspectorElementProperty: UIView] = [:]

    private func makeView(for property: InspectorElementProperty) -> UIView? {
        switch property {
        case let .preview(target: container):
            return LiveViewHierarchyElementThumbnailView(with: container.reference).then {
                $0.layer.cornerRadius = elementInspectorAppearance.elementInspectorCornerRadius / 2
            }

        case .separator:
            return SeparatorView(style: .medium).then {
                $0.contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
                    vertical: elementInspectorAppearance.horizontalMargins
                )
            }

        case let .group(title: title, subtitle: subtitle):
            return SectionHeader.attributesInspectorGroup(title: title, subtitle: subtitle)

        case let .infoNote(icon: noteIcon, title: title, text: text):
            return NoteControl(icon: noteIcon, title: title, text: text)

        case let .imagePicker(title: title, image: imageProvider, handler: _):
            return ImagePreviewControl(title: title, image: imageProvider()).then {
                $0.delegate = self
            }

        case let .textField(title: title, placeholder: placeholder, axis: axis, value: value, handler: _):
            return TextFieldControl(title: title, value: value(), placeholder: placeholder).then {
                $0.axis = axis
            }

        case let .stepper(title: title, value: valueProvider, range: rangeProvider, stepValue: stepValueProvider, isDecimalValue: isDecimalValue, handler: _):
            return StepperControl(
                title: title,
                value: valueProvider(),
                range: rangeProvider(),
                stepValue: stepValueProvider(),
                isDecimalValue: isDecimalValue
            )

        case let .colorPicker(title: title, emptyTitle: emptyTitle, color: colorProvider, handler: _):
            return ColorPreviewControl(
                title: title,
                emptyTitle: emptyTitle,
                color: colorProvider()
            ).then {
                $0.delegate = self
            }

        case let .switch(title: title, isOn: isOnProvider, handler: _):
            return ToggleControl(
                title: title,
                isOn: isOnProvider()
            )

        case let .imageButtonGroup(title: title, axis: axis, images: images, selectedIndex: selectedIndexProvider, _):
            return SegmentedControl(
                title: title,
                images: images,
                selectedIndex: selectedIndexProvider()
            ).then {
                $0.axis = axis
            }

        case let .textButtonGroup(title: title, axis: axis, texts: texts, selectedIndex: selectedIndexProvider, _):
            return SegmentedControl(
                title: title,
                texts: texts,
                selectedIndex: selectedIndexProvider()
            ).then {
                $0.axis = axis
            }

        case let .optionsList(title: title, emptyTitle: emptyTitle, axis: axis, options: options, selectedIndex: selectedIndexProvider, _):
            return OptionListControl(
                title: title,
                options: options,
                emptyTitle: emptyTitle,
                selectedIndex: selectedIndexProvider()
            ).then {
                $0.axis = axis
                $0.delegate = self
            }

        case let .textView(title: title, placeholder: placeholder, value: stringProvider, handler: _):
            return TextViewControl(
                title: title,
                value: stringProvider(),
                placeholder: placeholder
            )
        case let .cgRect(title: title, rect: rectProvider, handler: _):
            return RectControl(title: title, rect: rectProvider())

        case let .cgPoint(title: title, point: pointProvider, handler: _):
            return PointControl(title: title, point: pointProvider())

        case let .cgSize(title: title, size: sizeProvider, handler: _):
            return SizeControl(title: title, size: sizeProvider())

        case let .directionalInsets(title: title, insets: insetsProvider, handler: _):
            return DirectionalEdgeInsetsControl(title: title, insets: insetsProvider())

        case let .edgeInsets(title: title, insets: insetsProvider, handler: _):
            return EdgeInsetsControl(title: title, insets: insetsProvider())

        case let .uiOffset(title: title, offset: offsetProvider, handler: _):
            return OffsetControl(title: title, offset: offsetProvider())
        }
    }
}

// MARK: - Actions

extension InspectorElementSectionViewController {
    @objc private func stateChanged() {
        delegate?.inspectorElementSectionViewController(self, willChangeFrom: .none, to: viewCode.state)
    }

    @objc private func valueChanged(_ sender: AnyObject) {
        for (property, formView) in formViews where formView === sender {
            delegate?.inspectorElementSectionViewController(self, willUpdate: property)

            let updateValueOperation = MainThreadOperation(name: "update property value") {
                switch (property, formView) {
                case let (.stepper(_, _, _, _, _, handler), stepperControl as StepperControl):
                    handler?(stepperControl.value)

                case let (.colorPicker(_, _, _, handler), colorPicker as ColorPreviewControl):
                    handler?(colorPicker.selectedColor)

                case let (.switch(_, _, handler), toggleControl as ToggleControl):
                    handler?(toggleControl.isOn)

                case let (.textButtonGroup(_, _, _, _, handler), segmentedControl as SegmentedControl),
                     let (.imageButtonGroup(_, _, _, _, handler), segmentedControl as SegmentedControl):
                    handler?(segmentedControl.selectedIndex)

                case let (.optionsList(_, _, _, _, _, handler), optionSelector as OptionListControl):
                    handler?(optionSelector.selectedIndex)

                case let (.textField(_, _, _, _, handler), textFieldControl as TextFieldControl):
                    handler?(textFieldControl.value)

                case let (.textView(_, _, _, handler), textViewControl as TextViewControl):
                    handler?(textViewControl.value)

                case let (.imagePicker(_, _, handler), imagePicker as ImagePreviewControl):
                    handler?(imagePicker.image)

                case let (.cgRect(_, _, handler: handler), cgRectControl as RectControl):
                    handler?(cgRectControl.rect)

                case let (.cgPoint(_, _, handler: handler), cgPointControl as PointControl):
                    handler?(cgPointControl.point)

                case let (.cgSize(_, _, handler: handler), cgSizeControl as SizeControl):
                    handler?(cgSizeControl.size)

                case let (.uiOffset(_, _, handler: handler), uiOffsetControl as OffsetControl):
                    handler?(uiOffsetControl.offset)

                case let (.directionalInsets(_, _, handler: handler), insetsControl as DirectionalEdgeInsetsControl):
                    handler?(insetsControl.insets)

                case let (.edgeInsets(_, _, handler: handler), insetsControl as EdgeInsetsControl):
                    handler?(insetsControl.insets)

                case (.separator, _),
                     (.group, _):
                    break

                case (.stepper, _),
                     (.colorPicker, _),
                     (.switch, _),
                     (.textButtonGroup, _),
                     (.imageButtonGroup, _),
                     (.optionsList, _),
                     (.textField, _),
                     (.textView, _),
                     (.imagePicker, _),
                     (.cgRect, _),
                     (.cgSize, _),
                     (.cgPoint, _),
                     (.uiOffset, _),
                     (.edgeInsets, _),
                     (.directionalInsets, _),
                     (.infoNote, _),
                     (.preview, _):
                    assertionFailure("shouldn't happen")
                }
            }

            let didUpdateOperation = MainThreadOperation(name: "did update property value") { [weak self] in
                guard let self = self else { return }

                self.delegate?.inspectorElementSectionViewController(self, didUpdate: property)
            }

            didUpdateOperation.addDependency(updateValueOperation)

            delegate?.addOperationToQueue(updateValueOperation)
            delegate?.addOperationToQueue(didUpdateOperation)
        }
    }

    func reloadData() {
        for (property, formView) in formViews {
            switch (property, formView) {
            case (.separator, _),
                 (.group, _),
                 (.infoNote, _):
                break

            case let (.stepper(title: title, value: valueProvider, range: rangeProvider, stepValue: stepValueProvider, _, _), stepperControl as StepperControl):
                stepperControl.value = valueProvider()
                stepperControl.title = title
                stepperControl.range = rangeProvider()
                stepperControl.stepValue = stepValueProvider()

            case let (.colorPicker(title: title, _, color: selectedColorProvider, _), colorPicker as ColorPreviewControl):
                colorPicker.selectedColor = selectedColorProvider()
                colorPicker.title = title

            case let (.imagePicker(title: title, image: imageProvider, _), imagePicker as ImagePreviewControl):
                imagePicker.image = imageProvider()
                imagePicker.title = title

            case let (.switch(title: title, isOn: isOnProvider, _), toggleControl as ToggleControl):
                toggleControl.isOn = isOnProvider()
                toggleControl.title = title

            case let (.imageButtonGroup(title: title, _, _, selectedIndex: selectedIndexProvider, _), segmentedControl as SegmentedControl),
                 let (.textButtonGroup(title: title, _, _, selectedIndex: selectedIndexProvider, _), segmentedControl as SegmentedControl):
                segmentedControl.selectedIndex = selectedIndexProvider()
                segmentedControl.title = title

            case let (.optionsList(title: title, _, _, _, selectedIndex: selectedIndexProvider, _), optionSelector as OptionListControl):
                optionSelector.selectedIndex = selectedIndexProvider()
                optionSelector.title = title

            case let (.textField(title: title, placeholder: placeholder, _, value: valueProvider, _), textFieldControl as TextFieldControl):
                textFieldControl.value = valueProvider()
                textFieldControl.placeholder = placeholder
                textFieldControl.title = title

            case let (.textView(title: title, placeholder: placeholder, value: valueProvider, _), textViewControl as TextViewControl):
                textViewControl.value = valueProvider()
                textViewControl.placeholder = placeholder
                textViewControl.title = title

            case let (.cgRect(title: title, rect: rectProvider, _), cgRectControl as RectControl):
                cgRectControl.title = title
                cgRectControl.rect = rectProvider()

            case let (.cgPoint(title: title, point: pointProvider, _), cgPointControl as PointControl):
                cgPointControl.title = title
                cgPointControl.point = pointProvider()

            case let (.cgSize(title: title, size: sizeProvider, _), cgSizeControl as SizeControl):
                cgSizeControl.title = title
                cgSizeControl.size = sizeProvider()

            case let (.uiOffset(title: title, offset: offsetProvider, _), uiOffsetControl as OffsetControl):
                uiOffsetControl.title = title
                uiOffsetControl.offset = offsetProvider()

            case let (.directionalInsets(title: title, insets: insetsProvider, _), directionalInsetsControl as DirectionalEdgeInsetsControl):
                directionalInsetsControl.title = title
                directionalInsetsControl.insets = insetsProvider()

            case let (.edgeInsets(title: title, insets: insetsProvider, _), edgeInsetsControl as EdgeInsetsControl):
                edgeInsetsControl.title = title
                edgeInsetsControl.insets = insetsProvider()

            case let (.preview, thumbnailView as ViewHierarchyElementThumbnailView):
                thumbnailView.updateViews(afterScreenUpdates: false)

            case (.stepper, _),
                 (.colorPicker, _),
                 (.switch, _),
                 (.imageButtonGroup, _),
                 (.textButtonGroup, _),
                 (.optionsList, _),
                 (.textField, _),
                 (.textView, _),
                 (.imagePicker, _),
                 (.cgRect, _),
                 (.cgSize, _),
                 (.cgPoint, _),
                 (.uiOffset, _),
                 (.edgeInsets, _),
                 (.directionalInsets, _),
                 (.preview, _):
                assertionFailure("shouldn't happen")
            }
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
