//
//  UIAlertAction+Convenience.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - Actionable

extension ViewHierarchyLayer: Actionable {
    
    var unselectedActionTitle: String {
        "☐ \(description)"
    }
    
    var selectedActionTitle: String {
        "☑ \(description)"
    }

    var emptyActionTitle: String {
        "☐ No \(description) found"
    }
    
}
