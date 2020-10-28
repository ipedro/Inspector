//
//  AttributesInspectorSectionViewModelProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

protocol AttributesInspectorSectionViewModelProtocol: AnyObject {
    
    var title: String { get }
    
    var properties: [AttributesInspectorSectionProperty] { get }
    
    init?(view: UIView)
}
