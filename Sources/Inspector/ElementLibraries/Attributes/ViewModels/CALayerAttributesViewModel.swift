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

import QuartzCore
import UIKit

extension ElementInspectorAttributesLibrary {
    final class CALayerAttributesViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case opacity = "Opacity"
            case backgroundColor = "Background Color"
            case isHidden = "Hidden"
            case isDoubleSided = "Double Sided"
            case allowsEdgeAntialiasing = "Edge Antialiasing"
            case allowsGroupOpacity = "Group Opacity"
            case separatorMask
            case mask = "Mask"
            case masksToBounds = "Masks To Bounds"
            case separatorCornerRadius
            case cornerRadius = "Corner Radius"
            case maskedCorners = "Masked Corners"
            case groupBorder = "Border"
            case borderWidth = "Border Width"
            case borderColor = "Border Color"
            case groupShadow = "Shadow"
            case shadowOpacity = "Shadow Opacity"
            case shadowRadius = "Shadow Radius"
            case shadowOffset = "Shadow Offset"
            case shadowColor = "Shadow Color"
            case shadowPath = "Shadow Path"
        }

        let title = "Core Animation Layer"

        private(set) weak var layer: CALayer?

        init?(view: UIView) {
            layer = view.layer
        }

        var properties: [InspectorElementViewModelProperty] {
            guard let layer = layer else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .opacity:
                    return .floatStepper(
                        title: property.rawValue,
                        value: { layer.opacity },
                        range: { 0...1 },
                        stepValue: { 0.05 }
                    ) { opacity in
                        layer.opacity = opacity
                    }

                case .isHidden:
                    return .switch(
                        title: property.rawValue,
                        isOn: { layer.isHidden }
                    ) { isHidden in
                        layer.isHidden = isHidden
                    }

                case .masksToBounds:
                    return .switch(
                        title: property.rawValue,
                        isOn: { layer.masksToBounds }
                    ) { masksToBounds in
                        layer.masksToBounds = masksToBounds
                    }

                case .mask:
                    guard let mask = layer.mask else { return nil }

                    return .textField(
                        title: property.rawValue,
                        placeholder: property.rawValue,
                        value: { mask.debugDescription },
                        handler: nil
                    )

                case .isDoubleSided:
                    return .switch(
                        title: property.rawValue,
                        isOn: { layer.isDoubleSided }
                    ) { isDoubleSided in
                        layer.isDoubleSided = isDoubleSided
                    }

                case .cornerRadius:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { layer.cornerRadius },
                        range: { 0...min(layer.frame.height, layer.frame.width) },
                        stepValue: { 1 }
                    ) { cornerRadius in
                        layer.cornerRadius = cornerRadius
                    }

                case .maskedCorners:
                    return nil

                case .borderWidth:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { layer.borderWidth },
                        range: { 0...100 },
                        stepValue: { 1 }
                    ) { borderWidth in
                        layer.borderWidth = borderWidth
                    }

                case .borderColor:
                    return .cgColorPicker(
                        title: property.rawValue,
                        color: { layer.borderColor }
                    ) { borderColor in
                        layer.borderColor = borderColor
                    }

                case .backgroundColor:
                    return .cgColorPicker(
                        title: property.rawValue,
                        color: { layer.backgroundColor }
                    ) { backgroundColor in
                        layer.backgroundColor = backgroundColor
                    }

                case .shadowOpacity:
                    return .floatStepper(
                        title: property.rawValue,
                        value: { layer.shadowOpacity },
                        range: { 0...1 },
                        stepValue: { 0.05 }
                    ) { shadowOpacity in
                        layer.shadowOpacity = shadowOpacity
                    }

                case .shadowRadius:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { layer.shadowRadius },
                        range: { 0...100 },
                        stepValue: { 1 }
                    ) { shadowRadius in
                        layer.shadowRadius = shadowRadius
                    }

                case .shadowOffset:
                    return .cgSize(
                        title: property.rawValue,
                        size: { layer.shadowOffset }
                    ) {
                        guard let shadowOffset = $0 else { return }
                        layer.shadowOffset = shadowOffset
                    }

                case .shadowColor:
                    return .cgColorPicker(
                        title: property.rawValue,
                        color: { layer.shadowColor }
                    ) { shadowColor in
                        layer.shadowColor = shadowColor
                    }

                case .shadowPath:
                    guard let shadowPath = layer.shadowPath else { return nil }

                    return .textField(
                        title: property.rawValue,
                        placeholder: property.rawValue,
                        value: { String(describing: shadowPath) },
                        handler: nil
                    )

                case .allowsEdgeAntialiasing:
                    return .switch(
                        title: property.rawValue,
                        isOn: { layer.allowsEdgeAntialiasing }
                    ) { allowsEdgeAntialiasing in
                        layer.allowsEdgeAntialiasing = allowsEdgeAntialiasing
                    }

                case .allowsGroupOpacity:
                    return .switch(
                        title: property.rawValue,
                        isOn: { layer.allowsGroupOpacity }
                    ) { allowsGroupOpacity in
                        layer.allowsGroupOpacity = allowsGroupOpacity
                    }
                case .separatorMask,
                     .separatorCornerRadius:
                    return .separator

                case .groupBorder,
                     .groupShadow:
                    return .group(title: property.rawValue)
                }
            }
        }
    }
}
