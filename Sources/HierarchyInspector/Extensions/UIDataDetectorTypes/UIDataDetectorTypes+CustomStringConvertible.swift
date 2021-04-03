//
//  UIDataDetectorTypes+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIDataDetectorTypes: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .phoneNumber:
            return "Phone Number"
            
        case .link:
            return "Link"
            
        case .address:
            return "Address"
            
        case .calendarEvent:
            return "Calendar Event"
            
        case .shipmentTrackingNumber:
            return "Shipment Tracking Number"
            
        case .flightNumber:
            return "Flight Number"
            
        case .lookupSuggestion:
            return "Lookup Suggestion"
            
        case .all:
            return "All"
        
        default:
            return "\(self) (unsupported)"
        }
        
    }
    
}
