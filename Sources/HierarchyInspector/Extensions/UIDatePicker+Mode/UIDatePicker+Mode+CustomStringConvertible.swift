//
//  UIDatePicker.Mode+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

extension UIDatePicker.Mode: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .time:
            return "Time"
            
        case .date:
            return "Date"
            
        case .dateAndTime:
            return "Date And Time"
            
        case .countDownTimer:
            return "Count Down Timer"
            
        @unknown default:
            return "Unknown"
            
        }
    }
}
