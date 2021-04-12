//
//  HierarchyInspectableElementViewModelProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectableElementViewModelProtocol: AnyObject {
    
    var title: String { get }
    
    var properties: [HiearchyInspectableElementProperty] { get }
    
    init?(view: UIView)
}
