//
//  UIDatePickerStyle+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

@available(iOS 13.4, *)
extension UIDatePickerStyle: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .automatic:
            return "Automatic"
            
        case .wheels:
            return "Wheels"
        
        #if swift(>=5.3)
        case .compact:
            return "Compact"
        
        case .inline:
            return "Inline"
        #endif
            
        @unknown default:
            return "Unknown"
            
        }
    }
    
}
