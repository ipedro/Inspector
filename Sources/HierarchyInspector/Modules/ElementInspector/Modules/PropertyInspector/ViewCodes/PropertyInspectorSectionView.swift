//
//  PropertyInspectorSectionView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorSectionViewDelegate: AnyObject {
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTapColorPicker colorPicker: ColorPicker)
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTapOptionSelector optionSelector: OptionSelector)
}

final class PropertyInspectorSectionView: BaseView {
    weak var delegate: PropertyInspectorSectionViewDelegate?
    
    let title: String?
    
    let propertyInputs: [PropertyInspectorInput]
    
    lazy var controlsStackView = UIStackView(
        axis: .vertical,
        arrangedSubviews: arrangedSubviews,
        margins: .margins(top: 0, leading: 30, bottom: 15, trailing: 30)
    )
    
    private lazy var sectionHeader = SectionHeader(.body, text: title).then {
        $0.isHidden = title == nil
    }
    
    private lazy var arrangedSubviews: [UIView] = propertyInputs.compactMap { inputControls[$0] }
    
    private lazy var inputControls: [PropertyInspectorInput: BaseControl] = {
        var dict = [PropertyInspectorInput: BaseControl]()
        
        for (index, property) in propertyInputs.enumerated() {
            let control: BaseControl = {
                switch property {
                case let .integerStepper(title, value, range, stepValue, _):
                    return StepperControl(title: title, value: value, range: range, stepValue: stepValue)
                    
                case let .doubleStepper(title, value, range, stepValue, _):
                    return StepperControl(title: title, value: value, range: range, stepValue: stepValue)
                    
                case let .colorPicker(title, color, _):
                    return ColorPicker(title: title, color: color).then {
                        $0.delegate = self
                    }
                    
                case let .toggleButton(title, isOn, _):
                    return ToggleControl(title: title, isOn: isOn)
                    
                case let .segmentedControl(title, items, selectedSegmentIndex, _):
                    return SegmentedControl(title: title, items: items, selectedSegmentIndex: selectedSegmentIndex)
                    
                case let .optionSelector(title, options, selectedIndex, _):
                    return OptionSelector(title: title, options: options, selectedIndex: selectedIndex).then {
                        $0.delegate = self
                    }
                }
            }()
                
            control.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
            control.isShowingSeparator = index != propertyInputs.count - 1
            
            dict[property] = control
        }
        
        return dict
    }()
    
    // MARK: - Init
    
    init(section: PropertyInspectorInputSection) {
        title = section.title
        
        propertyInputs = section.propertyInpus

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(sectionHeader)
        
        contentView.addArrangedSubview(controlsStackView)
    }
}

// MARK: - Actions

private extension PropertyInspectorSectionView {
        
    @objc func valueChanged(_ sender: AnyObject) {
        
        for (property, control) in inputControls where control === sender {
            
            switch (property, control) {
            case let (.integerStepper(_, _, _, _, handler), stepperControl as StepperControl):
                handler(Int(stepperControl.value))
                
            case let (.doubleStepper(_, _, _, _, handler), stepperControl as StepperControl):
                handler(stepperControl.value)
                
            case let (.colorPicker(_, _, handler), colorPicker as ColorPicker):
                handler(colorPicker.selectedColor)
                
            case let (.toggleButton(_, _, handler), toggleControl as ToggleControl):
                handler(toggleControl.isOn)
                
            case let (.segmentedControl(_, _, _, handler), segmentedControl as SegmentedControl):
                handler(segmentedControl.selectedSegmentIndex)
                
            case let (.optionSelector(_, _, _, handler), optionSelector as OptionSelector):
                handler(optionSelector.selectedIndex)
                
            case (.integerStepper, _),
                 (.doubleStepper, _),
                 (.colorPicker, _),
                 (.toggleButton, _),
                 (.segmentedControl, _),
                 (.optionSelector, _):
                break
            }
        }
        
    }
}

// MARK: - ColorPickerDelegate

extension PropertyInspectorSectionView: ColorPickerDelegate {
    func colorPickerDidTap(_ colorPicker: ColorPicker) {
        delegate?.propertyInspectorSectionView(self, didTapColorPicker: colorPicker)
    }
}

extension PropertyInspectorSectionView: OptionSelectorDelegate {
    func optionSelectorDidTap(_ optionSelector: OptionSelector) {
        delegate?.propertyInspectorSectionView(self, didTapOptionSelector: optionSelector)
    }
}
