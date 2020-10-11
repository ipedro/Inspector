//
//  UIColor+Hex.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 05.10.20.
//

import UIKit

extension UIColor {
    
    // MARK: - From UIColor to String
    
    var hexDescription: String? {
        
        guard self != .clear else {
            return "Clear Color"
        }
        
        guard let hexColor = toHex() else {
            return grayscaleDescription
        }
        
        guard rgba.alpha < 1 else {
            return hexColor
        }
        
        let alphaPercentage = Int(rgba.alpha * 100)
    
        return "\(hexColor) (\(alphaPercentage)%)"
    }
    
    private var grayscaleDescription: String? {
        var white: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getWhite(&white, alpha: &alpha) else {
            return nil
        }
        
        let whitePercentage = Int(white * 100)
        let alphaPercentage = Int(alpha * 100)
        
        return "White \(whitePercentage)% (\(alphaPercentage)%)"
    }

    private func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}
