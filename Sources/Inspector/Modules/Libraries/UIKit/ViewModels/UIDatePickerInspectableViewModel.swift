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

extension UIKitElementLibrary {
    final class UIDatePickerInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case datePickerStyle = "Style"
            case datePickerMode = "Mode"
            case locale = "Locale"
            case minuteInterval = "Interval"
        }
        
        let title = "Date Picker"
        
        private(set) weak var datePicker: UIDatePicker?
        
        init?(view: UIView) {
            guard let datePicker = view as? UIDatePicker else {
                return nil
            }
            
            self.datePicker = datePicker
        }
        
        private let minuteIntervalRange = 1...30
        
        private lazy var validMinuteIntervals = minuteIntervalRange.filter { 60 % $0 == 0 }
        
        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
            guard let datePicker = datePicker else {
                return nil
            }

            switch property {
            case .datePickerStyle:
                #if swift(>=5.3)
                if #available(iOS 13.4, *) {
                    return .optionsList(
                        title: property.rawValue,
                        options: UIDatePickerStyle.allCases.map(\.description),
                        selectedIndex: { UIDatePickerStyle.allCases.firstIndex(of: datePicker.datePickerStyle) }
                    ) {
                        guard let newIndex = $0 else {
                            return
                        }
                        
                        let datePickerStyle = UIDatePickerStyle.allCases[newIndex]
                        
                        if #available(iOS 14.0, *) {
                            if
                                datePicker.datePickerMode == .countDownTimer,
                                datePickerStyle == .inline || datePickerStyle == .compact
                            {
                                datePicker.datePickerMode = .dateAndTime
                            }
                        }
                        
                        datePicker.preferredDatePickerStyle = datePickerStyle
                    }
                }
                #endif
                return nil
                
            case .datePickerMode:
                return .optionsList(
                    title: property.rawValue,
                    options: UIDatePicker.Mode.allCases.map(\.description),
                    selectedIndex: { UIDatePicker.Mode.allCases.firstIndex(of: datePicker.datePickerMode) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let datePickerMode = UIDatePicker.Mode.allCases[newIndex]
                    
                    #if swift(>=5.3)
                    if #available(iOS 14.0, *) {
                        if
                            datePickerMode == .countDownTimer,
                            datePicker.datePickerStyle == .inline || datePicker.datePickerStyle == .compact
                        {
                            return
                        }
                    }
                    #endif
                    
                    datePicker.datePickerMode = datePickerMode
                }
                
            case .locale:
                return nil
                
            case .minuteInterval:
                return .optionsList(
                    title: property.rawValue,
                    options: validMinuteIntervals.map { "\($0) \($0 == 1 ? "minute" : "minutes")" },
                    selectedIndex: { self.validMinuteIntervals.firstIndex(of: datePicker.minuteInterval) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let minuteInterval = self.validMinuteIntervals[newIndex]
                    
                    datePicker.minuteInterval = minuteInterval
                }
            }
        }
    }
}
