//
//  UIImage+ModuleImage.swift
//  HierarchyInspector
//
//  Created by Pedro on 12.04.21.
//

import UIKit

extension UIImage {
    
    static func moduleImage(named imageName: String) -> UIImage {
        guard let image = UIImage(named: imageName, in: .module, compatibleWith: nil) else {
            fatalError("Couldn't find image named \(imageName)")
        }
        return image
    }
    
}
