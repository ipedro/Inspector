//
//  ViewHierarchyReference+ElementDescription.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import Foundation

extension ViewHierarchyReference {
    
    var elementDescription: String {
        var strings = [String?]()
        
        var constraints: String? {
            guard let view = view else {
                return nil
            }
            return "\(view.constraints.count) constraints"
        }
        
        var subviews: String? {
            guard isContainer else {
                return nil
            }
            return "\(flattenedViewHierarchy.count) children. (\(children.count) subviews)"
        }
        
        var frame: String? {
            guard let view = view else {
                return nil
            }
            
            return "x: \(view.frame.origin.x), y: \(view.frame.origin.y) – w: \(view.frame.width), h: \(view.frame.height)"
        }
        
        var className: String? {
            guard let view = view else {
                return nil
            }
            
            guard let superclass = view.superclass else {
                return view.className
            }
            
            return "\(view.className) (\(String(describing: superclass)))"
        }
        
        strings.append(className)
        
        strings.append(frame)
        
        strings.append(subviews)
        
        strings.append(constraints)
        
        return strings.compactMap { $0 }.joined(separator: "\n")
    }
}
