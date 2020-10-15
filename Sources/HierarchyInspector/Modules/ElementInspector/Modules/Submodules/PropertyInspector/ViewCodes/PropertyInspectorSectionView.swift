//
//  PropertyInspectorSectionView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorSectionViewDelegate: AnyObject {
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTap colorPicker: ColorPicker)
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTap optionSelector: OptionSelector)
    func propertyInspectorSectionViewDidTapHeader(_ section: PropertyInspectorSectionView, isCollapsed: Bool)
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didUpdate property: PropertyInspectorInput)
    func propertyInspectorSectionViewWillUpdateProperty(_ section: PropertyInspectorSectionView)
}

final class PropertyInspectorSectionView: BaseView {
    weak var delegate: PropertyInspectorSectionViewDelegate?
    
    let title: String?
    
    let propertyInputs: [PropertyInspectorInput]
    
    lazy var controlsStackView = UIStackView(
        axis: .vertical,
        arrangedSubviews: arrangedSubviews
    )
    
    private lazy var topSeparatorView = SeparatorView(thickness: 1)
    
    private lazy var sectionHeader = SectionHeader(.callout, text: title, withTraits: .traitBold).then {
        $0.contentView.directionalLayoutMargins = .margins(
            horizontal: .zero,
            vertical: ElementInspector.appearance.verticalMargins / 2
        )
        
        $0.isHidden = title == nil
    }
    
    var isCollapsed: Bool {
        didSet {
            hideContent(isCollapsed)
        }
    }
    
    private lazy var arrangedSubviews: [UIView] = propertyInputs.compactMap { inputViews[$0] }
    
    private lazy var inputViews: [PropertyInspectorInput: UIView] = {
        var dict = [PropertyInspectorInput: UIView]()
        
        for (index, property) in propertyInputs.enumerated() {
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
                    
                case let .integerStepper(title, value, range, stepValue, _):
                    return StepperControl(
                        title: title,
                        value: value,
                        range: range,
                        stepValue: stepValue
                    )
                    
                case let .cgFloatStepper(title, value, range, stepValue, _):
                    return StepperControl(
                        title: title,
                        value: Double(value),
                        range: Double(range.lowerBound) ... Double(range.upperBound),
                        stepValue: Double(stepValue)
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
                    
                case let .inlineTextOptions(title, customStringConvertibles, selectedSegmentIndex, _):
                    return SegmentedControl(
                        title: title,
                        items: customStringConvertibles.map { $0.description.localizedCapitalized },
                        selectedSegmentIndex: selectedSegmentIndex
                    )

                case let .inlineImageOptions(title, images, selectedSegmentIndex, _):
                    return SegmentedControl(
                        title: title,
                        items: images,
                        selectedSegmentIndex: selectedSegmentIndex
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
                
                let isLastElement = index == propertyInputs.count - 1
                
                let isNotFollowedByControl = index + 1 < propertyInputs.count && propertyInputs[index + 1].isControl == false
                
                control.isShowingSeparator = (isLastElement || isNotFollowedByControl) == false
                
                control.isEnabled = property.hasHandler
            }
            
            dict[property] = element
        }
        
        return dict
    }()
    
    private lazy var toggleControl = UIControl().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.addTarget(self, action: #selector(tapHeader), for: .touchUpInside)
    }
    
    private lazy var chevronDownIcon = Icon.chevronDownIcon()
    
    // MARK: - Init
    
    init(section: PropertyInspectorSectionViewModelProtocol, isCollapsed: Bool) {
        self.isCollapsed = isCollapsed
        
        self.title = section.title
        
        self.propertyInputs = section.propertyInpus

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        hideContent(isCollapsed)
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        contentView.directionalLayoutMargins = ElementInspector.appearance.margins
        
        contentView.addArrangedSubview(sectionHeader)
        
        contentView.addArrangedSubview(controlsStackView)
        
        contentView.setCustomSpacing(ElementInspector.appearance.verticalMargins, after: sectionHeader)
        
        installSeparator()
        
        installIcon()
        
        installHeaderControl()
    }
    
    private func installHeaderControl() {
        contentView.addSubview(toggleControl)
        
        toggleControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toggleControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        toggleControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toggleControl.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor).isActive = true
    }
    
    private func installIcon() {
        contentView.addSubview(chevronDownIcon)
        
        chevronDownIcon.centerYAnchor.constraint(equalTo: sectionHeader.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(
            equalTo: sectionHeader.leadingAnchor,
            constant: -(ElementInspector.appearance.verticalMargins / 3)
        ).isActive = true
    }
    
    private func installSeparator() {
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topSeparatorView)
    
        topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    @objc private func tapHeader() {
        delegate?.propertyInspectorSectionViewDidTapHeader(self, isCollapsed: isCollapsed)
    }
    
    private func hideContent(_ hide: Bool) {
        controlsStackView.clipsToBounds  = hide
        controlsStackView.isSafelyHidden = hide
        controlsStackView.alpha          = hide ? 0 : 1
        chevronDownIcon.transform        = hide ? CGAffineTransform(rotationAngle: -(.pi / 2)) : .identity
    }
}

// MARK: - Actions

private extension PropertyInspectorSectionView {
        
    @objc func valueChanged(_ sender: AnyObject) {
        delegate?.propertyInspectorSectionViewWillUpdateProperty(self)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            for (property, inputView) in self.inputViews where inputView === sender {
                
                switch (property, inputView) {
                case let (.integerStepper(_, _, _, _, handler), stepperControl as StepperControl):
                    handler?(Int(stepperControl.value))
                    
                case let (.cgFloatStepper(_, _, _, _, handler), stepperControl as StepperControl):
                    handler?(CGFloat(stepperControl.value))
                    
                case let (.colorPicker(_, _, handler), colorPicker as ColorPicker):
                    handler?(colorPicker.selectedColor)
                    
                case let (.toggleButton(_, _, handler), toggleControl as ToggleControl):
                    handler?(toggleControl.isOn)
                    
                case let (.inlineTextOptions(_, _, _, handler), segmentedControl as SegmentedControl),
                     let (.inlineImageOptions(_, _, _, handler), segmentedControl as SegmentedControl):
                    handler?(segmentedControl.selectedIndex)
                    
                case let (.optionsList(_, _, _, handler), optionSelector as OptionSelector):
                    handler?(optionSelector.selectedIndex)
                    
                case (.separator, _),
                     (.subSection, _),
                     (.integerStepper, _),
                     (.cgFloatStepper, _),
                     (.colorPicker, _),
                     (.toggleButton, _),
                     (.inlineTextOptions, _),
                     (.inlineImageOptions, _),
                     (.optionsList, _):
                    break
                }
                
                self.delegate?.propertyInspectorSectionView(self, didUpdate: property)
            }
        }
    }
}

// MARK: - ColorPickerDelegate

extension PropertyInspectorSectionView: ColorPickerDelegate {
    func colorPickerDidTap(_ colorPicker: ColorPicker) {
        delegate?.propertyInspectorSectionView(self, didTap: colorPicker)
    }
}

extension PropertyInspectorSectionView: OptionSelectorDelegate {
    func optionSelectorDidTap(_ optionSelector: OptionSelector) {
        delegate?.propertyInspectorSectionView(self, didTap: optionSelector)
    }
}
