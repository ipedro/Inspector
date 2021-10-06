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

extension ElementInspectorAttributesLibrary {
    final class UISliderAttributesViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case value = "Value"
            case minimumValue = "Minimum"
            case maximumValue = "Maximum"
            case groupImages = "Images"
            case minimumValueImage = "Min Image"
            case maximumValueImage = "Max Image"
            case groupColors = "Colors"
            case minimumTrackTintColor = "Min Track"
            case maxTrack = "Max Track"
            case thumbTintColor = "Thumb Tint"
            case groupEvent = "Event"
            case isContinuous = "Continuous updates"
        }

        let title = "Slider"

        private(set) weak var slider: UISlider?

        init?(view: UIView) {
            guard let slider = view as? UISlider else {
                return nil
            }

            self.slider = slider
        }

        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
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
                    range: { 0...max(0, slider.maximumValue) },
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
                return .separator

            case .minimumValueImage:
                return .imagePicker(
                    title: property.rawValue,
                    image: { slider.minimumValueImage }
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
                return .separator

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
                return .switch(
                    title: property.rawValue,
                    isOn: { slider.isContinuous }
                ) { isContinuous in
                    slider.isContinuous = isContinuous
                }
            }
        }
    }
}
