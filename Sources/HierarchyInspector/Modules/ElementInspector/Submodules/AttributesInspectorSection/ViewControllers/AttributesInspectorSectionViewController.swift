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
                                                  didUpdate property: AttributesInspectorSectionProperty)
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  willUpdate property: AttributesInspectorSectionProperty)
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didToggle isCollapsed: Bool)
    
}

final class AttributesInspectorSectionViewController: UIViewController {
    weak var delegate: AttributesInspectorSectionViewControllerDelegate?
    
    private(set) lazy var viewCode = AttributesInspectorSectionViewCode().then {
        $0.delegate = self
    }
    
    private var viewModel: AttributesInspectorSectionViewModelProtocol!
    
    static func create(viewModel: AttributesInspectorSectionViewModelProtocol) -> AttributesInspectorSectionViewController {
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
    
    private lazy var inputViews: [AttributesInspectorSectionProperty: UIView] = {
        var dict = [AttributesInspectorSectionProperty: UIView]()
        
        for (index, property) in viewModel.properties.enumerated() {
            let element: UIView = {
                switch property {
                case .separator:
                    return SeparatorView().then {
                        $0.contentView.directionalLayoutMargins = .margins(
                            horizontal: .zero,
                            vertical: ElementInspector.configuration.appearance.verticalMargins
                        )
                    }
                    
                case let .group(title):
                    return SectionHeader(
                        .footnote,
                        text: title
                    ).then {
                        $0.contentView.directionalLayoutMargins = .margins(
                            top: ElementInspector.configuration.appearance.horizontalMargins,
                            bottom: ElementInspector.configuration.appearance.verticalMargins
                        )
                        $0.alpha = 1 / 3
                    }
                    
                case let .imagePicker(title, imageProvider, _):
                    return ImagePreviewControl(title: title, image: imageProvider()).then {
                        $0.delegate = self
                    }
                    
                case let .textInput(title, value, placeholder, _):
                    return TextInputControl(title: title, value: value(), placeholder: placeholder())
                    
                case let .stepper(title, valueProvider, rangeProvider, stepValueProvider, isDecimal, _):
                    return StepperControl(
                        title: title,
                        value: valueProvider(),
                        range: rangeProvider(),
                        stepValue: stepValueProvider(),
                        isDecimalValue: isDecimal
                    )
                    
                case let .colorPicker(title, colorProvider, _):
                    return ColorPreviewControl(
                        title: title,
                        color: colorProvider()
                    ).then {
                        $0.delegate = self
                    }
                    
                case let .toggleButton(title, isOnProvider, _):
                    return ToggleControl(
                        title: title,
                        isOn: isOnProvider()
                    )
                    
                case let .segmentedControl(title, options, axis, selectedIndexProvider, _):
                    return SegmentedControl(
                        title: title,
                        options: options,
                        selectedIndex: selectedIndexProvider()
                    ).then {
                        $0.axis = axis
                    }
                    
                case let .optionsList(title, options, axis, emptyTitle, selectedIndexProvider, _):
                    return OptionListControl(
                        title: title,
                        options: options,
                        emptyTitle: emptyTitle,
                        selectedIndex: selectedIndexProvider()
                    ).then {
                        $0.axis = axis
                        $0.delegate = self
                    }
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
                    
                case let (.segmentedControl(_, _, _, _, handler), segmentedControl as SegmentedControl):
                    handler?(segmentedControl.selectedIndex)
                    
                case let (.optionsList(_, _, _, _, _, handler), optionSelector as OptionListControl):
                    handler?(optionSelector.selectedIndex)
                    
                case let (.textInput(_, _, _, handler), textInputControl as TextInputControl):
                    handler?(textInputControl.value)
                    
                case let (.imagePicker(_, _, handler), imagePicker as ImagePreviewControl):
                    handler?(imagePicker.selectedImage)
                    
                case (.separator, _),
                     (.group, _):
                     break
                    
                case (.stepper, _),
                     (.colorPicker, _),
                     (.toggleButton, _),
                     (.segmentedControl, _),
                     (.optionsList, _),
                     (.textInput, _),
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
            
            case let (.stepper(_, valueProvider, rangeProvider, stepValueProvider, _, _), stepperControl as StepperControl):
                stepperControl.value     = valueProvider()
                stepperControl.range     = rangeProvider()
                stepperControl.stepValue = stepValueProvider()
                
            case let (.colorPicker(_, selectedColorProvider, _), colorPicker as ColorPreviewControl):
                colorPicker.selectedColor = selectedColorProvider()
                
            case let (.imagePicker(_, imageProvider, _), imagePicker as ImagePreviewControl):
                imagePicker.selectedImage = imageProvider()
                
            case let (.toggleButton(_, isOnProvider, _), toggleControl as ToggleControl):
                toggleControl.isOn = isOnProvider()
                
            case let (.segmentedControl(_, _, _, selectedIndexProvider, _), segmentedControl as SegmentedControl):
                segmentedControl.selectedIndex = selectedIndexProvider()
                
            case let (.optionsList(_, _, _, _, selectedIndexProvider, _), optionSelector as OptionListControl):
                optionSelector.selectedIndex = selectedIndexProvider()
                
            case let (.textInput(_, valueProvider, placeholderProvider, _), textInputControl as TextInputControl):
                textInputControl.placeholder = placeholderProvider()
                textInputControl.value = valueProvider()
                
            case (.separator, _),
                 (.group, _):
                 break
            
            case (.stepper, _),
                 (.colorPicker, _),
                 (.toggleButton, _),
                 (.segmentedControl, _),
                 (.optionsList, _),
                 (.textInput, _),
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
