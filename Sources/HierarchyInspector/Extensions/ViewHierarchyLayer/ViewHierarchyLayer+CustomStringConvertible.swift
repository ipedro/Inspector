//
//  ViewHierarchyLayer+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import Foundation

// MARK: - CustomStringConvertible

extension ViewHierarchyLayer: CustomStringConvertible {
    
    var description: String {
        guard name.contains(",+") || name.contains(",-") else {
            return name
        }
        
        let components = name.components(separatedBy: ",")
        
        var additions  = [String]()
        var exclusions = [String]()
            
        components.forEach {
            if $0 == components.first {
                additions.append($0)
            }
            
            if $0.first == "+" {
                additions.append(String($0.dropFirst()))
            }
            
            if $0.first == "-" {
                exclusions.append(String($0.dropFirst()))
            }
        }
        
        var displayName = String()
        
        additions.enumerated().forEach { index, name in
            if index == 0 {
                displayName = name
                return
            }
            
            if index == additions.count - 1 {
                displayName += " and \(name)"
            }
            else {
                displayName += ", \(name)"
            }
        }
        
        guard exclusions.isEmpty == false else {
            return displayName
        }
        
        exclusions.enumerated().forEach { index, name in
            if index == 0 {
                displayName += " excl․ \(name)"
                return
            }
            
            if index == additions.count - 1 {
                displayName += " and \(name)"
            }
            else {
                displayName += ", \(name)"
            }
        }
        
        return displayName
    }
    
}
