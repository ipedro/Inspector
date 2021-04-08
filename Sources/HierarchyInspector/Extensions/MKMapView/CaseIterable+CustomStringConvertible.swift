//
//  CaseIterable+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.12.20.
//

import MapKit

extension MKMapType: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .standard:
            return "Standard"
            
        case .satellite:
            return "Satellite"
            
        case .hybrid:
            return "Hybrid"
            
        case .satelliteFlyover:
            return "Satellite Flyover"
            
        case .hybridFlyover:
            return "Hybrid Flyover"
            
        case .mutedStandard:
            return "Muted Standard"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    
}
