//
//  PropertyInspectorSectionViewModelProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

protocol PropertyInspectorSectionViewModelProtocol: AnyObject {
    
    var title: String { get }
    
    var properties: [PropertyInspectorSectionProperty] { get }
    
    init?(view: UIView)
}
