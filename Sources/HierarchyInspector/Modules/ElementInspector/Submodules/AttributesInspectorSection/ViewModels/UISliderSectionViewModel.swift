//
//  UISliderSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {

    final class UISliderSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: CaseIterable {
            case value
            case minimumValue
            case maximumValue
            case separator0
            case minimumValueImage
            case maximumValueImage
            case separator1
            case minimumTrackTintColor
            case maxTrack
            case thumbTintColor
            case groupEvent
            case isContinuous
        }
        
        private(set) weak var slider: UISlider?
        
        init?(view: UIView) {
            guard let slider = view as? UISlider else {
                return nil
            }
            
            self.slider = slider
        }
        
        let title = "Slider"
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap {
            guard let slider = slider else {
                return nil
            }
            
            let stepValueProvider = { max(0.01, (slider.maximumValue - slider.minimumValue) / 100) }

            switch $0 {
                
            case .value:
                return .floatStepper(
                    title: "value",
                    value: { slider.value },
                    range: { slider.minimumValue...slider.maximumValue },
                    stepValue: stepValueProvider
                ) { value in
                    slider.value = value
                    slider.sendActions(for: .valueChanged)
                }
            
            case .minimumValue:
                return .floatStepper(
                    title: "minimum",
                    value: { slider.minimumValue },
                    range: { 0...slider.maximumValue} ,
                    stepValue: stepValueProvider
                ) { minimumValue in
                    slider.minimumValue = minimumValue
                }
            
            case .maximumValue:
                return .floatStepper(
                    title: "maximum",
                    value: { slider.maximumValue },
                    range: { slider.minimumValue...Float.infinity },
                    stepValue: stepValueProvider
                ) { maximumValue in
                    slider.maximumValue = maximumValue
                }
            
            case .separator0,
                 .separator1:
                return .separator
            
            case .minimumValueImage:
                return .imagePicker(
                    title: "min image",
                     image: { slider.minimumValueImage}
                ) { minimumValueImage in
                    slider.minimumValueImage = minimumValueImage
                }
            
            case .maximumValueImage:
                return .imagePicker(
                    title: "max image",
                    image: { slider.maximumValueImage }
                ) { maximumValueImage in
                    slider.maximumValueImage = maximumValueImage
                }
            
            case .minimumTrackTintColor:
                return .colorPicker(
                    title: "min track",
                    color: { slider.minimumTrackTintColor }
                ) { minimumTrackTintColor in
                    slider.minimumTrackTintColor = minimumTrackTintColor
                }
            
            case .maxTrack:
                return .colorPicker(
                    title: "max track",
                    color: { slider.maximumTrackTintColor }
                ) { maximumTrackTintColor in
                    slider.maximumTrackTintColor = maximumTrackTintColor
                }
            
            case .thumbTintColor:
                return .colorPicker(
                    title: "thumb tint",
                    color: { slider.thumbTintColor }
                ) { thumbTintColor in
                    slider.thumbTintColor = thumbTintColor
                }
            
            case .groupEvent:
                return .subSection(name: "Event")
                
            case .isContinuous:
                return .toggleButton(
                    title: "continuous updates",
                    isOn: { slider.isContinuous }
                ) { isContinuous in
                    slider.isContinuous = isContinuous
                }
            }
            
        }
    }

}
