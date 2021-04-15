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

extension Sequence where Element == HierarchyInspectableElementProtocol {
    
    func targeting(element: NSObject) -> [HierarchyInspectableElementProtocol] {
        
        let validInspectors = element.classesForCoder.flatMap { aClass -> [HierarchyInspectableElementProtocol] in
            filter { $0.targetClass == aClass }
        }
        
        return validInspectors
    }
    
}
