//
//  AttributesInspectorSectionView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol AttributesInspectorSectionViewControllerDelegate: OperationQueueManagerProtocol {
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didTap colorPicker: ColorPreviewControl)
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didTap imagePicker: ImagePreviewControl)
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didTap optionSelector: OptionListControl)
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didUpdate property: HiearchyInspectableElementProperty)
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  willUpdate property: HiearchyInspectableElementProperty)
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didToggle isCollapsed: Bool)
    
}

final class AttributesInspectorSectionViewController: UIViewController {
    weak var delegate: AttributesInspectorSectionViewControllerDelegate?
    
    private(set) lazy var viewCode = AttributesInspectorSectionViewCode().then {
        $0.delegate = self
    }
    
    private var viewModel: HierarchyInspectorElementViewModelProtocol!
    
    static func create(viewModel: HierarchyInspectorElementViewModelProtocol) -> AttributesInspectorSectionViewController {
        let viewController = AttributesInspectorSectionViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCode.sectionHeader.text = viewModel.title
        
        viewModel.properties.forEach {
            guard let view = inputViews[$0] else {
                return
            }
            
            viewCode.inputContainerView.addArrangedSubview(view)
        }
    }
    
    var isCollapsed: Bool {
        get {
            viewCode.isCollapsed
        }
        set {
            viewCode.isCollapsed = newValue
        }
    }
    
    private lazy var inputViews: [HiearchyInspectableElementProperty: UIView] = {
        var dict = [HiearchyInspectableElementProperty: UIView]()
        
        for (index, property) in viewModel.properties.enumerated() {
            let element: UIView? = {
                switch property {
                case .separator:
                    return SeparatorView().then {
                        $0.contentView.directionalLayoutMargins = .margins(
                            horizontal: .zero,
                            vertical: ElementInspector.appearance.verticalMargins
                        )
                    }
                    
                case let .group(title):
                    return SectionHeader.attributesInspectorGroup(title: title)
                    
                case let .imagePicker(title: title, image: imageProvider, handler: _):
                    return ImagePreviewControl(title: title, image: imageProvider()).then {
                        $0.delegate = self
                    }
                    
                case let .textField(title: title, placeholder: placeholder, value: value, handler: _):
                    return TextFieldControl(title: title, value: value(), placeholder: placeholder())
                    
                case let .stepper(title: title, value: valueProvider, range: rangeProvider, stepValue: stepValueProvider, isDecimalValue: isDecimalValue, handler: _):
                    return StepperControl(
                        title: title,
                        value: valueProvider(),
                        range: rangeProvider(),
                        stepValue: stepValueProvider(),
                        isDecimalValue: isDecimalValue
                    )
                    
                case let .colorPicker(title: title, color: colorProvider, handler: _):
                    return ColorPreviewControl(
                        title: title,
                        color: colorProvider()
                    ).then {
                        $0.delegate = self
                    }
                    
                case let .toggleButton(title: title, isOn: isOnProvider, handler: _):
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
                    
                case let .textView(title: title, placeholder: placeholderProvider, value: stringProvider, handler: _):
                    return TextViewControl(
                        title: title,
                        value: stringProvider(),
                        placeholder: placeholderProvider()
                    )
                }
            }()
            
            if let control = element as? BaseFormControl {
                control.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
                
                let isLastElement = index == viewModel.properties.count - 1
                
                let isNotFollowedByControl = index + 1 < viewModel.properties.count && viewModel.properties[index + 1].isControl == false
                
                control.isShowingSeparator = (isLastElement || isNotFollowedByControl) == false
                
                control.isEnabled = property.hasHandler
            }
            
            dict[property] = element
        }
        
        return dict
    }()
    
}

// MARK: - Actions

extension AttributesInspectorSectionViewController {
        
    @objc private func valueChanged(_ sender: AnyObject) {
        handleChange(with: sender)
    }
    
    private func handleChange(with sender: AnyObject) {
        for (property, inputView) in self.inputViews where inputView === sender {
            
            delegate?.attributesInspectorSectionViewController(self, willUpdate:property)
            
            let updateValueOperation = MainThreadOperation(name: "update property value") {
                
                switch (property, inputView) {
                case let (.stepper(_, _, _, _, _, handler), stepperControl as StepperControl):
                    handler?(stepperControl.value)
                    
                case let (.colorPicker(_, _, handler), colorPicker as ColorPreviewControl):
                    handler?(colorPicker.selectedColor)
                    
                case let (.toggleButton(_, _, handler), toggleControl as ToggleControl):
                    handler?(toggleControl.isOn)
                    
                case let (.textButtonGroup(_, _, _, _, handler), segmentedControl as SegmentedControl),
                     let (.imageButtonGroup(_, _, _, _, handler), segmentedControl as SegmentedControl):
                    handler?(segmentedControl.selectedIndex)
                    
                case let (.optionsList(_, _, _, _, _, handler), optionSelector as OptionListControl):
                    handler?(optionSelector.selectedIndex)
                    
                case let (.textField(_, _, _, handler), textFieldControl as TextFieldControl):
                    handler?(textFieldControl.value)
                
                case let (.textView(_, _, _, handler), textViewControl as TextViewControl):
                    handler?(textViewControl.value)
                
                case let (.imagePicker(_, _, handler), imagePicker as ImagePreviewControl):
                    handler?(imagePicker.selectedImage)
                    
                case (.separator, _),
                     (.group, _):
                     break
                    
                case (.stepper, _),
                     (.colorPicker, _),
                     (.toggleButton, _),
                     (.textButtonGroup, _),
                     (.imageButtonGroup, _),
                     (.optionsList, _),
                     (.textField, _),
                     (.textView, _),
                     (.imagePicker, _):
                    assertionFailure("shouldn't happen")
                    break
                }
                
            }
            
            let didUpdateOperation = MainThreadOperation(name: "did update property value") { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.delegate?.attributesInspectorSectionViewController(self, didUpdate: property)
            }
            
            didUpdateOperation.addDependency(updateValueOperation)
            
            delegate?.addOperationToQueue(updateValueOperation)
            delegate?.addOperationToQueue(didUpdateOperation)
        }
    }
    
    func updateValues() {
        for (property, inputView) in self.inputViews {
            
            switch (property, inputView) {
            
            case let (.stepper(title: title, value: valueProvider, range: rangeProvider, stepValue: stepValueProvider, _, _), stepperControl as StepperControl):
                stepperControl.value     = valueProvider()
                stepperControl.title     = title
                stepperControl.range     = rangeProvider()
                stepperControl.stepValue = stepValueProvider()
                
            case let (.colorPicker(title: title, color: selectedColorProvider, _), colorPicker as ColorPreviewControl):
                colorPicker.selectedColor = selectedColorProvider()
                colorPicker.title = title
                
            case let (.imagePicker(title: title, image: imageProvider, _), imagePicker as ImagePreviewControl):
                imagePicker.selectedImage = imageProvider()
                imagePicker.title = title
                
            case let (.toggleButton(title: title, isOn: isOnProvider, _), toggleControl as ToggleControl):
                toggleControl.isOn = isOnProvider()
                toggleControl.title = title
                
            case let (.imageButtonGroup(title: title, _, _, selectedIndex: selectedIndexProvider, _), segmentedControl as SegmentedControl),
                 let ( .textButtonGroup(title: title, _, _, selectedIndex: selectedIndexProvider, _), segmentedControl as SegmentedControl):
                segmentedControl.selectedIndex = selectedIndexProvider()
                segmentedControl.title = title
                
            case let (.optionsList(title: title, _, _, _, selectedIndex: selectedIndexProvider, _), optionSelector as OptionListControl):
                optionSelector.selectedIndex = selectedIndexProvider()
                optionSelector.title = title
                
            case let (.textField(title: title, placeholder: placeholderProvider, value: valueProvider, _), textFieldControl as TextFieldControl):
                textFieldControl.value = valueProvider()?.trimmed
                textFieldControl.placeholder = placeholderProvider()?.trimmed
                textFieldControl.title = title
                
            case let (.textView(title: title, placeholder: placeholderProvider, value: valueProvider, _), textViewControl as TextViewControl):
                textViewControl.value = valueProvider()?.trimmed
                textViewControl.placeholder = placeholderProvider()?.trimmed
                textViewControl.title = title
                
            case (.separator, _),
                 (.group, _):
                 break
            
            case (.stepper, _),
                 (.colorPicker, _),
                 (.toggleButton, _),
                 (.imageButtonGroup, _),
                 (.textButtonGroup, _),
                 (.optionsList, _),
                 (.textField, _),
                 (.textView, _),
                 (.imagePicker, _):
                assertionFailure("shouldn't happen")
                break
            }
            
        }
    }
}

// MARK: - ColorPreviewControlDelegate

extension AttributesInspectorSectionViewController: ColorPreviewControlDelegate {
    func colorPreviewControlDidTap(_ colorPreviewControl: ColorPreviewControl) {
        delegate?.attributesInspectorSectionViewController(self, didTap: colorPreviewControl)
    }
}

// MARK: - OptionListControlDelegate

extension AttributesInspectorSectionViewController: OptionListControlDelegate {
    func optionListControlDidTap(_ optionListControl: OptionListControl) {
        delegate?.attributesInspectorSectionViewController(self, didTap: optionListControl)
    }
}

// MARK: - ImagePreviewControlDelegate

extension AttributesInspectorSectionViewController: ImagePreviewControlDelegate {
    func imagePreviewControlDidTap(_ imagePreviewControl: ImagePreviewControl) {
        delegate?.attributesInspectorSectionViewController(self, didTap: imagePreviewControl)
    }
}

// MARK: - AttributesInspectorSectionViewCodeDelegate

extension AttributesInspectorSectionViewController: AttributesInspectorSectionViewCodeDelegate {
    func attributesInspectorSectionViewCode(_ section: AttributesInspectorSectionViewCode, didToggle isCollapsed: Bool) {
        delegate?.attributesInspectorSectionViewController(self, didToggle: isCollapsed)
    }
}
