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
import UIKit

extension DefaultElementAttributesLibrary {
    final class DatePickerAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Date Picker"

        private weak var datePicker: UIDatePicker?

        init?(with object: NSObject) {
            guard let datePicker = object as? UIDatePicker else { return nil }

            self.datePicker = datePicker
        }

        private let minuteIntervalRange = 1...30

        private lazy var validMinuteIntervals = minuteIntervalRange.filter { 60 % $0 == 0 }

        private enum Property: String, Swift.CaseIterable {
            case datePickerStyle = "Style"
            case datePickerMode = "Mode"
            case locale = "Locale"
            case minuteInterval = "Interval"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let datePicker else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .datePickerStyle:
                    .init(
                        descriptor: .init(
                            id: "date-picker-style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIDatePickerStyle.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIDatePickerStyle.allCases.firstIndex(of: datePicker.datePickerStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let datePickerStyle = UIDatePickerStyle.allCases[newIndex]

                            if
                                datePicker.datePickerMode == .countDownTimer,
                                datePickerStyle == .inline || datePickerStyle == .compact
                            {
                                datePicker.datePickerMode = .dateAndTime
                            }

                            datePicker.preferredDatePickerStyle = datePickerStyle
                        }
                    )

                case .datePickerMode:
                    .init(
                        descriptor: .init(
                            id: "date-picker-mode",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIDatePicker.Mode.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIDatePicker.Mode.allCases.firstIndex(of: datePicker.datePickerMode)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let datePickerMode = UIDatePicker.Mode.allCases[newIndex]

                            if
                                datePickerMode == .countDownTimer,
                                datePicker.datePickerStyle == .inline || datePicker.datePickerStyle == .compact
                            {
                                return
                            }

                            datePicker.datePickerMode = datePickerMode
                        }
                    )

                case .locale:
                    nil

                case .minuteInterval:
                    .init(
                        descriptor: .init(
                            id: "minute-interval",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: validMinuteIntervals.enumerated().map {
                                    .init(id: "\($0.offset)", title: "\($0.element) \($0.element == 1 ? "minute" : "minutes")")
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(self.validMinuteIntervals.firstIndex(of: datePicker.minuteInterval)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let minuteInterval = self.validMinuteIntervals[newIndex]

                            datePicker.minuteInterval = minuteInterval
                        }
                    )
                }
            }
        }
    }
}
