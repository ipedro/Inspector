//
//  Icon.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

extension Icon {
    enum Glyph {
        case chevronDown
        case chevronUpDown
        case infoCircle
        case wifiExlusionMark
        case eyeSlashFill
        case listBulletIndent
        case search
        
        func draw(color: UIColor, frame: CGRect, resizing: IconKit.ResizingBehavior) {
            switch self {
            case .chevronDown:
                IconKit.drawChevronDown(color: color, frame: frame, resizing: resizing)
                
            case .infoCircle:
                IconKit.drawInfoCircleFill(color: color, frame: frame, resizing: resizing)
            
            case .wifiExlusionMark:
                IconKit.drawWifiExlusionMark(color: color, frame: frame, resizing: resizing)
                
            case .eyeSlashFill:
                IconKit.drawEyeSlashFill(color: color, frame: frame, resizing: resizing)
                
            case .listBulletIndent:
                IconKit.drawListBulletIndent(color: color, frame: frame, resizing: resizing)
                
            case .chevronUpDown:
                IconKit.drawChevronUpDown(color: color, frame: frame, resizing: resizing)
                
            case .search:
                IconKit.drawSearch(color: color, frame: frame, resizing: resizing)
            }
        }
    }
}
