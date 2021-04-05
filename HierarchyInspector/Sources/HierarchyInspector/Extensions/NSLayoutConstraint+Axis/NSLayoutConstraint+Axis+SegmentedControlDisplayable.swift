//
//  NSLayoutConstraint.Axis+SegmentedControlDisplayable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension NSLayoutConstraint.Axis: SegmentedControlDisplayable {
    var displayItem: Any {
        switch self {
        case .horizontal:
            return "Horizontal"
            
        case .vertical:
            return "Vertical"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
