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

import InspectorContract
import QuartzCore
import UIKit

extension DefaultElementAttributesLibrary {
    final class LayerAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String

        private weak var layer: CALayer?

        init?(with object: NSObject) {
            guard let view = object as? UIView else { return nil }
            layer = view.layer
            title = view.layer._prettyClassNameWithoutQualifiers
        }

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

        var propertyBindings: [InspectorPropertyBinding] {
            guard let layer else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .opacity:
                    return .init(
                        descriptor: .init(id: "opacity", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 1, step: 0.05, isDecimal: true)), editability: .editable),
                        read: { .number(Double(layer.opacity)) },
                        write: { newValue in guard case let .number(value) = newValue else { return }; layer.opacity = Float(value) }
                    )
                case .backgroundColor:
                    return .init(
                        descriptor: .init(id: "background-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                        read: { .color(layer.backgroundColor.map { UIColor(cgColor: $0) }) },
                        write: { newValue in guard case let .color(color) = newValue else { return }; layer.backgroundColor = color?.cgColor }
                    )
                case .isHidden:
                    return .init(descriptor: .init(id: "is-hidden", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(layer.isHidden) }, write: { newValue in guard case let .bool(v)=newValue else { return }; layer.isHidden = v })
                case .isDoubleSided:
                    return .init(descriptor: .init(id: "is-double-sided", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(layer.isDoubleSided) }, write: { newValue in guard case let .bool(v)=newValue else { return }; layer.isDoubleSided = v })
                case .allowsEdgeAntialiasing:
                    return .init(descriptor: .init(id: "allows-edge-antialiasing", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(layer.allowsEdgeAntialiasing) }, write: { newValue in guard case let .bool(v)=newValue else { return }; layer.allowsEdgeAntialiasing = v })
                case .allowsGroupOpacity:
                    return .init(descriptor: .init(id: "allows-group-opacity", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(layer.allowsGroupOpacity) }, write: { newValue in guard case let .bool(v)=newValue else { return }; layer.allowsGroupOpacity = v })
                case .separatorMask, .separatorCornerRadius:
                    return .init(descriptor: .init(id: property.rawValue, title: "", kind: .separator, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
                case .mask:
                    guard let mask = layer.mask else { return nil }
                    return .init(descriptor: .init(id: "mask", title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: property.rawValue, allowsNil: false)), editability: .readOnly), read: { .string(mask.debugDescription) }, write: nil, refreshHint: .none)
                case .masksToBounds:
                    return .init(descriptor: .init(id: "masks-to-bounds", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(layer.masksToBounds) }, write: { newValue in guard case let .bool(v)=newValue else { return }; layer.masksToBounds = v })
                case .cornerRadius:
                    return .init(descriptor: .init(id: "corner-radius", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: Double(min(layer.frame.height, layer.frame.width)), step: 1, isDecimal: true)), editability: .editable), read: { .number(Double(layer.cornerRadius)) }, write: { newValue in guard case let .number(v)=newValue else { return }; layer.cornerRadius = CGFloat(v) })
                case .maskedCorners:
                    return nil
                case .groupBorder, .groupShadow:
                    return .init(descriptor: .init(id: property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(), title: property.rawValue, kind: .group, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
                case .borderWidth:
                    return .init(descriptor: .init(id: "border-width", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 100, step: 1, isDecimal: true)), editability: .editable), read: { .number(Double(layer.borderWidth)) }, write: { newValue in guard case let .number(v)=newValue else { return }; layer.borderWidth = CGFloat(v) })
                case .borderColor:
                    return .init(descriptor: .init(id: "border-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(layer.borderColor.map { UIColor(cgColor: $0) }) }, write: { newValue in guard case let .color(color)=newValue else { return }; layer.borderColor = color?.cgColor })
                case .shadowOpacity:
                    return .init(descriptor: .init(id: "shadow-opacity", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 1, step: 0.05, isDecimal: true)), editability: .editable), read: { .number(Double(layer.shadowOpacity)) }, write: { newValue in guard case let .number(v)=newValue else { return }; layer.shadowOpacity = Float(v) })
                case .shadowRadius:
                    return .init(descriptor: .init(id: "shadow-radius", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 100, step: 1, isDecimal: true)), editability: .editable), read: { .number(Double(layer.shadowRadius)) }, write: { newValue in guard case let .number(v)=newValue else { return }; layer.shadowRadius = CGFloat(v) })
                case .shadowOffset:
                    return .init(descriptor: .init(id: "shadow-offset", title: property.rawValue, kind: .preview, value: .size, editability: .editable), read: { .size(layer.shadowOffset) }, write: { newValue in guard case let .size(v)=newValue else { return }; layer.shadowOffset = v })
                case .shadowColor:
                    return .init(descriptor: .init(id: "shadow-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(layer.shadowColor.map { UIColor(cgColor: $0) }) }, write: { newValue in guard case let .color(color)=newValue else { return }; layer.shadowColor = color?.cgColor })
                case .shadowPath:
                    guard let shadowPath = layer.shadowPath else { return nil }
                    return .init(descriptor: .init(id: "shadow-path", title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: property.rawValue, allowsNil: false)), editability: .readOnly), read: { .string(String(describing: shadowPath)) }, write: nil, refreshHint: .none)
                }
            }
        }
    }
}
