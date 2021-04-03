//
//  UIDatePickerSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 31.10.20.
//

import UIKit

extension AttributesInspectorSection {
    
    final class UIDatePickerSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: String, Swift.CaseIterable {
            case datePickerStyle = "Style"
            case datePickerMode  = "Mode"
            case locale          = "Locale"
            case minuteInterval  = "Interval"
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
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let datePicker = datePicker else {
                return nil
            }

            switch property {
            
            case .datePickerStyle:
                #if swift(>=5.3)
                if #available(iOS 13.4, *) {
                    return .optionsList(
                        title: property.rawValue,
                        options: UIDatePickerStyle.allCases,
                        selectedIndex: { UIDatePickerStyle.allCases.firstIndex(of: datePicker.datePickerStyle ) }
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
                    options: UIDatePicker.Mode.allCases,
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
