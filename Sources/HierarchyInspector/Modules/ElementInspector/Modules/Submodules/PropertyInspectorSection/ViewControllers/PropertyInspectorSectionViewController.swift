//
//  PropertyInspectorSectionView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorSectionViewControllerDelegate: AnyObject {
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController,
                                                didTap colorPicker: ColorPicker)
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController,
                                                didTap imagePicker: ImagePicker)
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController,
                                                didTap optionSelector: OptionSelector)
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController,
                                                didUpdate property: PropertyInspectorSectionProperty)
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController,
                                                willUpdate property: PropertyInspectorSectionProperty)
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController,
                                                didToggle isCollapsed: Bool)
    
}

final class PropertyInspectorSectionViewController: UIViewController {
    weak var delegate: PropertyInspectorSectionViewControllerDelegate?
    
    private(set) lazy var viewCode = PropertyInspectorSectionViewCode().then {
        $0.delegate = self
    }
    
    private var viewModel: PropertyInspectorSectionViewModelProtocol!
    
    static func create(viewModel: PropertyInspectorSectionViewModelProtocol) -> PropertyInspectorSectionViewController {
        let viewController = PropertyInspectorSectionViewController()
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
    
    private lazy var inputViews: [PropertyInspectorSectionProperty: UIView] = {
        var dict = [PropertyInspectorSectionProperty: UIView]()
        
        for (index, property) in viewModel.properties.enumerated() {
            let element: UIView = {
                switch property {
                case .separator:
                    return SeparatorView().then {
                        $0.contentView.directionalLayoutMargins = .margins(
                            horizontal: .zero,
                            vertical: ElementInspector.appearance.verticalMargins
                        )
                    }
                    
                case let .subSection(title):
                    return SectionHeader(
                        .footnote,
                        text: title.localizedCapitalized
                    ).then {
                        $0.contentView.directionalLayoutMargins = .margins(
                            top: ElementInspector.appearance.horizontalMargins,
                            bottom: ElementInspector.appearance.verticalMargins
                        )
                        $0.alpha = 1 / 3
                    }
                    
                case let .imagePicker(title, image, _):
                    return ImagePicker(title: title, image: image).then {
                        $0.delegate = self
                    }
                    
                case let .textInput(title, value, placeholder, _):
                    return TextInputControl(title: title, value: value, placeholder: placeholder)
                    
                case let .stepper(title, value, range, stepValue, isDecimal, _):
                    return StepperControl(
                        title: title,
                        value: Double(value),
                        range: Double(range.lowerBound) ... Double(range.upperBound),
                        stepValue: Double(stepValue),
                        isDecimalValue: isDecimal
                    )
                    
                case let .colorPicker(title, color, _):
                    return ColorPicker(
                        title: title,
                        color: color
                    ).then {
                        $0.delegate = self
                    }
                    
                case let .toggleButton(title, isOn, _):
                    return ToggleControl(
                        title: title,
                        isOn: isOn
                    )
                    
                case let .segmentedControl(title, options, selectedSegmentIndex, _):
                    return SegmentedControl(
                        title: title,
                        options: options,
                        selectedIndex: selectedSegmentIndex
                    )
                    
                case let .optionsList(title, options, selectedIndex, _):
                    return OptionSelector(
                        title: title,
                        options: options,
                        selectedIndex: selectedIndex
                    ).then {
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

private extension PropertyInspectorSectionViewController {
        
    @objc func valueChanged(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] in
            self?.handleChange(with: sender)
        }
    }
    
    func handleChange(with sender: AnyObject) {
        for (property, inputView) in self.inputViews where inputView === sender {
            self.delegate?.propertyInspectorSectionViewController(self, willUpdate:property)
            
            switch (property, inputView) {
            case let (.stepper(_, _, _, _, _, handler), stepperControl as StepperControl):
                handler?(stepperControl.value)
                
            case let (.colorPicker(_, _, handler), colorPicker as ColorPicker):
                handler?(colorPicker.selectedColor)
                
            case let (.toggleButton(_, _, handler), toggleControl as ToggleControl):
                handler?(toggleControl.isOn)
                
            case let (.segmentedControl(_, _, _, handler), segmentedControl as SegmentedControl):
                handler?(segmentedControl.selectedIndex)
                
            case let (.optionsList(_, _, _, handler), optionSelector as OptionSelector):
                handler?(optionSelector.selectedIndex)
                
            case let (.textInput(_, _, _, handler), textInputControl as TextInputControl):
                handler?(textInputControl.value)
                
            case let (.imagePicker(_, _, handler), imagePicker as ImagePicker):
                handler?(imagePicker.selectedImage)
                
            case (.separator, _),
                 (.subSection, _),
                 (.stepper, _),
                 (.colorPicker, _),
                 (.toggleButton, _),
                 (.segmentedControl, _),
                 (.optionsList, _),
                 (.textInput, _),
                 (.imagePicker, _):
                break
            }
            
            self.delegate?.propertyInspectorSectionViewController(self, didUpdate: property)
            
        }
    }
}

// MARK: - ColorPickerDelegate

extension PropertyInspectorSectionViewController: ColorPickerDelegate {
    func colorPickerDidTap(_ colorPicker: ColorPicker) {
        delegate?.propertyInspectorSectionViewController(self, didTap: colorPicker)
    }
}

// MARK: - OptionSelectorDelegate

extension PropertyInspectorSectionViewController: OptionSelectorDelegate {
    func optionSelectorDidTap(_ optionSelector: OptionSelector) {
        delegate?.propertyInspectorSectionViewController(self, didTap: optionSelector)
    }
}

// MARK: - ImagePickerDelegate

extension PropertyInspectorSectionViewController: ImagePickerDelegate {
    func imagePickerDidTap(_ imagePicker: ImagePicker) {
        delegate?.propertyInspectorSectionViewController(self, didTap: imagePicker)
    }
}

// MARK: - PropertyInspectorSectionViewCodeDelegate

extension PropertyInspectorSectionViewController: PropertyInspectorSectionViewCodeDelegate {
    func propertyInspectorSectionViewCode(_ section: PropertyInspectorSectionViewCode, didToggle isCollapsed: Bool) {
        delegate?.propertyInspectorSectionViewController(self, didToggle: isCollapsed)
    }
}
