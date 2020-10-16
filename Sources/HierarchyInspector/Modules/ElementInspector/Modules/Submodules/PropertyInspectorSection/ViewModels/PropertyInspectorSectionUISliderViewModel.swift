//
//  PropertyInspectorSectionUISliderViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class PropertyInspectorSectionUISliderViewModel: PropertyInspectorSectionViewModelProtocol {
    
    enum Property: CaseIterable {
        case value
        case minimumValue
        case maximum
        case separator0
        case minImage
        case maxImage
        case separator1
        case minTrack
        case maxTrack
        case thumbTintColor
        case isContinuous
    }
    
    private(set) weak var slider: UISlider?
    
    init(slider: UISlider) {
        self.slider = slider
    }
    
    let title = "Slider"
    
    private(set) lazy var properties: [PropertyInspectorSectionProperty] = Property.allCases.compactMap {
        guard let slider = slider else {
            return nil
        }

        switch $0 {
            
        case .value:
            return .floatStepper(
                title: "value",
                value: slider.value,
                range: slider.minimumValue...slider.maximumValue,
                stepValue: (slider.maximumValue - slider.minimumValue) / 100
            ) { value in
                slider.value = value
                slider.sendActions(for: .valueChanged)
            }
        
        case .minimumValue:
            return .floatStepper(
                title: "minimum",
                value: slider.minimumValue,
                range: 0...slider.maximumValue,
                stepValue: (slider.maximumValue - slider.minimumValue) / 100
            ) { minimumValue in
                slider.minimumValue = minimumValue
            }
        
        case .maximum:
            return .floatStepper(
                title: "maximum",
                value: slider.maximumValue,
                range: slider.minimumValue...Float.infinity,
                stepValue: (slider.maximumValue - slider.minimumValue) / 100
            ) { minimumValue in
                slider.minimumValue = minimumValue
            }
        
        case .separator0,
             .separator1:
            return .separator
        
        case .minImage:
            return nil
        
        case .maxImage:
            return nil
        
        case .minTrack:
            return nil
        
        case .maxTrack:
            return nil
        
        case .thumbTintColor:
            return .colorPicker(
                title: "thumb tint",
                color: slider.thumbTintColor
            ) { thumbTintColor in
                slider.thumbTintColor = thumbTintColor
            }
        
        case .isContinuous:
            return .toggleButton(
                title: "continuous event updates",
                isOn: slider.isContinuous
            ) { isContinuous in
                slider.isContinuous = isContinuous
            }
        }
        
    }
}
