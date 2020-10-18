//
//  UISwitch.Style+SegmentedControlDisplayable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import UIKit

#if swift(>=5.3)
@available(iOS 14.0, *)
extension UISwitch.Style: SegmentedControlDisplayable {
    var displayItem: Any {
        switch self {
        case .automatic:
            return "Automatic"
            
        case .checkbox:
            return "Checkbox"
            
        case .sliding:
            return "Sliding"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
#endif
