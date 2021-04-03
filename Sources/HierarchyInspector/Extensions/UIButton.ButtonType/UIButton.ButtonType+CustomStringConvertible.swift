//
//  UIButton.ButtonType+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIButton.ButtonType: CustomStringConvertible {
    
    var description: String {
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            switch self {
            
            case .custom:
                return "Custom"
                
            case .system:
                return "System"
                
            case .detailDisclosure:
                return "Detail Disclosure"
                
            case .infoLight:
                return "Info Light"
                
            case .infoDark:
                return "Info Dark"
                
            case .contactAdd:
                return "Contact Add"
                
            case .close:
                return "Close"
                
            @unknown default:
                return "Unknown"
                
            }
        }
        #endif
        switch self {
        
        case .custom:
            return "Custom"
            
        case .system:
            return "System"
            
        case .detailDisclosure:
            return "Detail Disclosure"
            
        case .infoLight:
            return "Info Light"
            
        case .infoDark:
            return "Info Dark"
            
        case .contactAdd:
            return "Contact Add"
            
        default:
            return "Unknown"
            
        }
    }
    
}
