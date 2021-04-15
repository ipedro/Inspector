//
//  HierarchyInspectorElementLibraryProtocol.swift
//  
//
//  Created by Pedro on 12.04.21.
//

import UIKit

public protocol HierarchyInspectorElementLibraryProtocol {
    
    var targetClass: AnyClass { get }
    
    func viewModel(with referenceView: UIView) -> HierarchyInspectorElementViewModelProtocol?
    
    func icon(with referenceView: UIView) -> UIImage?
    
}

extension Sequence where Element == HierarchyInspectorElementLibraryProtocol {
    
    func targeting(element: NSObject) -> [HierarchyInspectorElementLibraryProtocol] {
        element.classesForCoder.flatMap { aElementClass in
            filter { $0.targetClass == aElementClass }
        }
    }
    
}
