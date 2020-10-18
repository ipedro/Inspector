//
//  UIView+Snapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 18.10.20.
//

import UIKit

extension UIView {
    func snapshot(afterScreenUpdates: Bool, with size: CGSize? = nil) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
        
        return image.resized(size ?? bounds.size)
    }
}
