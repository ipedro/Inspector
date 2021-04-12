//
//  HiearchyInspectableElementProtocol.swift
//  
//
//  Created by Pedro on 12.04.21.
//

import UIKit

public protocol HiearchyInspectableElementProtocol {
    
    var targetClass: AnyClass { get }
    
    func viewModel(with referenceView: UIView) -> HiearchyInspectableElementViewModelProtocol?
    
    var icon: UIImage? { get }
    
}

extension HiearchyInspectableElementProtocol {
    
    func targets(object: NSObject) -> Bool {
        for anyClass in object.classesForCoder where anyClass == targetClass {
            return true
        }
        return false
    }
    
}
