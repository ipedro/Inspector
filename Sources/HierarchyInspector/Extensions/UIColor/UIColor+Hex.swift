//
//  UIColor+Hex.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 05.10.20.
//

import UIKit

extension UIColor {
    
    typealias Hex = UInt32
    
    convenience init(hex: Hex, alpha: CGFloat = 1.0) {
        let mask = 0x000000FF
        let r = Int(hex >> 16) & mask
        let g = Int(hex >> 8) & mask
        let b = Int(hex) & mask
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
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
        
        switch whitePercentage {
        case 50:
            return "Gray (\(alphaPercentage)%)"
            
        case let percentage where percentage < 50:
            return " \(100 - percentage)% Black (\(alphaPercentage)%)"
            
        default:
            return "\(whitePercentage)% White (\(alphaPercentage)%)"
        }
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
