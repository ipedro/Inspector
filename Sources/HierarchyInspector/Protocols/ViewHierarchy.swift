//
//  ViewHierarchy.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

protocol ViewHierarchy {
    /// Determines if a view can host an inspector view.
    var canHostInspectorView: Bool { get }
    
    var isSystemView: Bool { get }
    
    /// String representation of the class name.
    var className: String { get }
    
    /// If a view has accessibility identifiers the last component will be shown, otherwise shows the class name.
    var elementName: String { get }
    
    var canPresentOnTop: Bool { get }
}
