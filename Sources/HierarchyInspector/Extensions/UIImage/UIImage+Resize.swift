//
//  UIImage+Resize.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 18.10.20.
//

import AVFoundation
import UIKit

extension UIImage {
    
    func resized(_ size: CGSize) -> UIImage {
        
        let aspectRect = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(origin: .zero, size: size))
        
        let renderer = UIGraphicsImageRenderer(size: aspectRect.size)
        
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: aspectRect.size))
        }.withRenderingMode(renderingMode)
        
    }
    
}
