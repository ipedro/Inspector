//
//  NSObject+ClassesForCoder.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import Foundation

extension NSObject {
    var classesForCoder: [AnyClass] {
        var array = [classForCoder]
        
        var objectClass: AnyClass = classForCoder
        
        while (objectClass.superclass() != nil) {
            guard let superclass = objectClass.superclass() else {
                break
            }
            
            array.append(superclass)
            objectClass = superclass
        }
        
        return array
    }
    
}
