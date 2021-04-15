//
//  ViewHierarchyLayer+Actionable.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - Actionable

extension ViewHierarchyLayer: Actionable {
    
    var unselectedActionTitle: String {
        Texts.unselectedActionTitle(with: description)
    }
    
    var selectedActionTitle: String {
        Texts.selectedActionTitle(with: description)
    }

    var emptyActionTitle: String {
        Texts.emptyActionTitle(with: description)
    }
    
}
