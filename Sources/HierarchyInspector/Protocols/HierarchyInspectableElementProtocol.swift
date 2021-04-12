//
//  HierarchyInspectableElementProtocol.swift
//  
//
//  Created by Pedro on 12.04.21.
//

import UIKit

public protocol HierarchyInspectableElementProtocol {
    
    var targetClass: AnyClass { get }
    
    func viewModel(with referenceView: UIView) -> HierarchyInspectableElementViewModelProtocol?
    
    func icon(with referenceView: UIView) -> UIImage?
    
}

extension HierarchyInspectableElementProtocol {
    
    func targets(object: NSObject) -> Bool {
        for anyClass in object.classesForCoder where anyClass == targetClass {
            return true
        }
        return false
    }
    
}
