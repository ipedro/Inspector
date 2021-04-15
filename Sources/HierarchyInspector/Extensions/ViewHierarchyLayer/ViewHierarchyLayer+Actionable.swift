//
//  ViewHierarchyLayer+Actionable.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - Actionable

extension ViewHierarchyLayer: Actionable {
    
    var title: String {
        description
    }

    var emptyActionTitle: String {
        Texts.emptyLayer(with: description)
    }
    
}
