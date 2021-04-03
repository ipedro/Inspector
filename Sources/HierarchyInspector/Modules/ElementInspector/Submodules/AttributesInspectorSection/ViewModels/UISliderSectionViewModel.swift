//
//  UISliderSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {

    final class UISliderSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: String, Swift.CaseIterable {
            case value                 = "Value"
            case minimumValue          = "Minimum"
            case maximumValue          = "Maximum"
            case groupImages           = "Images"
            case minimumValueImage     = "Min Image"
            case maximumValueImage     = "Max Image"
            case groupColors           = "Colors"
            case minimumTrackTintColor = "Min Track"
            case maxTrack              = "Max Track"
            case thumbTintColor        = "Thumb Tint"
            case groupEvent            = "Event"
            case isContinuous          = "Continuous updates"
        }
        
        let title = "Slider"
        
        private(set) weak var slider: UISlider?
        
        init?(view: UIView) {
            guard let slider = view as? UISlider else {
                return nil
            }
            
            self.slider = slider
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let slider = slider else {
                return nil
            }
            
            let stepValueProvider = { max(0.01, (slider.maximumValue - slider.minimumValue) / 100) }

            switch property {
                
            case .value:
                return .floatStepper(
                    title: property.rawValue,
                    value: { slider.value },
                    range: { min(slider.minimumValue, slider.maximumValue)...max(slider.minimumValue, slider.maximumValue) },
                    stepValue: stepValueProvider
                ) { value in
                    slider.value = value
                    slider.sendActions(for: .valueChanged)
                }
            
            case .minimumValue:
                return .floatStepper(
                    title: property.rawValue,
                    value: { slider.minimumValue },
                    range: { 0...max(0, slider.maximumValue) } ,
                    stepValue: stepValueProvider
                ) { minimumValue in
                    slider.minimumValue = minimumValue
                }
            
            case .maximumValue:
                return .floatStepper(
                    title: property.rawValue,
                    value: { slider.maximumValue },
                    range: { slider.minimumValue...Float.infinity },
                    stepValue: stepValueProvider
                ) { maximumValue in
                    slider.maximumValue = maximumValue
                }
            
            case .groupImages:
                return .separator(title: property.rawValue)
            
            case .minimumValueImage:
                return .imagePicker(
                    title: property.rawValue,
                     image: { slider.minimumValueImage}
                ) { minimumValueImage in
                    slider.minimumValueImage = minimumValueImage
                }
            
            case .maximumValueImage:
                return .imagePicker(
                    title: property.rawValue,
                    image: { slider.maximumValueImage }
                ) { maximumValueImage in
                    slider.maximumValueImage = maximumValueImage
                }
            
            case .groupColors:
                return .separator(title: property.rawValue)
            
            case .minimumTrackTintColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { slider.minimumTrackTintColor }
                ) { minimumTrackTintColor in
                    slider.minimumTrackTintColor = minimumTrackTintColor
                }
            
            case .maxTrack:
                return .colorPicker(
                    title: property.rawValue,
                    color: { slider.maximumTrackTintColor }
                ) { maximumTrackTintColor in
                    slider.maximumTrackTintColor = maximumTrackTintColor
                }
            
            case .thumbTintColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { slider.thumbTintColor }
                ) { thumbTintColor in
                    slider.thumbTintColor = thumbTintColor
                }
            
            case .groupEvent:
                return .group(title: property.rawValue)
                
            case .isContinuous:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { slider.isContinuous }
                ) { isContinuous in
                    slider.isContinuous = isContinuous
                }
            }
            
        }
    }

}
