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

extension DefaultElementIdentityLibrary {
    final class RuntimeAttributesIdentitySectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Runtime Attributes"

        private(set) weak var object: NSObject?

        private let propertyNames: [String]

        private let hideUknownValues: Bool = true

        init(with object: NSObject) {
            self.object = object
            propertyNames = object
                .propertyNames()
                .sorted(by: <)
        }

        var properties: [InspectorElementProperty] {
            guard
                let object = object,
                !propertyNames.isEmpty
            else {
                return [
                    .infoNote(icon: .info, title: "No Inspectable Properties", text: .none)
                ]
            }

            return propertyNames.compactMap { property in
                let title = property
                    .replacingOccurrences(of: "_", with: "")
                    .camelCaseToWords()
                    .localizedCapitalized

                guard
                    object.responds(to: Selector(property)),
                    let result = object.safeValue(forKey: property)
                else {
                    if hideUknownValues {
                        return nil
                    }
                    return .textField(
                        title: title,
                        placeholder: .none,
                        axis: .horizontal,
                        value: { nil },
                        handler: nil
                    )
                }

                switch result {
                case let colorValue as UIColor:
                    return .colorPicker(
                        title: title,
                        color: { colorValue },
                        handler: nil
                    )
                case let imageValue as UIImage:
                    return .imagePicker(
                        title: title,
                        image: { imageValue },
                        handler: nil
                    )
                case let number as NSNumber:
                    return .stepper(
                        title: title,
                        value: { number.doubleValue },
                        range: { 0...max(1, number.doubleValue) },
                        stepValue: { 1 },
                        isDecimalValue: Double(number.intValue) != number.doubleValue,
                        handler: nil
                    )
                case let boolValue as Bool:
                    return .switch(
                        title: title,
                        isOn: { boolValue },
                        handler: nil
                    )
                case let size as CGSize:
                    return .cgSize(
                        title: title,
                        size: { size },
                        handler: nil
                    )
                case let point as CGPoint:
                    return .cgPoint(
                        title: title,
                        point: { point },
                        handler: nil
                    )
                case let rect as CGRect:
                    return .cgRect(
                        title: title,
                        rect: { rect },
                        handler: nil
                    )
                case let insets as NSDirectionalEdgeInsets:
                    return .directionalInsets(
                        title: title,
                        insets: { insets },
                        handler: nil
                    )
                case let insets as UIEdgeInsets:
                    return .edgeInsets(
                        title: title,
                        insets: { insets },
                        handler: nil
                    )
                case let view as UIView:
                    return .textView(
                        title: title,
                        placeholder: nil,
                        value: { view.elementDescription },
                        handler: nil
                    )
                case let aClass as AnyClass:
                    return .textField(
                        title: title,
                        placeholder: nil,
                        axis: .horizontal,
                        value: { String(describing: aClass) },
                        handler: nil
                    )
                case let object as NSObject:
                    return .textView(
                        title: title,
                        placeholder: nil,
                        value: { object.debugDescription },
                        handler: nil
                    )
                case let stringValue as String:
                    return .textView(
                        title: title,
                        placeholder: nil,
                        value: { stringValue },
                        handler: nil
                    )
                default:
                    return nil
                }
            }
        }
    }
}
