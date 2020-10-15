//
//  UISwitch.Style+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import UIKit

#if swift(>=5.3)
@available(iOS 14.0, *)
extension UISwitch.Style: CustomStringConvertible {
    public var description: String {
        switch self {
        case .automatic:
            return "automatic"
            
        case .checkbox:
            return "checkbox"
            
        case .sliding:
            return "sliding"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
#endif

