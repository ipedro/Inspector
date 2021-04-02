//
//  AttributesInspectorSectionProperty+Font.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.12.20.
//

import UIKit

extension AttributesInspectorSectionProperty {
    
    static func fontNamePicker(
        title: String,
        emptyTitle: String = "System Font",
        fontProvider: @escaping FontProvider,
        handler: @escaping FontHandler
    ) -> AttributesInspectorSectionProperty {
        
        typealias FontReference = (fontName: String, displayName: String)
        
        let availableFonts: [FontReference] = {
            
            var array = [FontReference("", emptyTitle)]
            
            UIFont.familyNames.forEach { familyName in
                
                let familyNames = UIFont.fontNames(forFamilyName: familyName)
                
                if
                    familyNames.count == 1,
                    let fontName = familyNames.first
                {
                    array.append((fontName: fontName, displayName: familyName))
                    return
                }
                
                familyNames.forEach { fontName in
                    guard
                        let lastName = fontName.split(separator: "-").last,
                        lastName.replacingOccurrences(of: " ", with: "")
                        .caseInsensitiveCompare(familyName.replacingOccurrences(of: " ", with: "")) != .orderedSame
                    else {
                        array.append((fontName: fontName, displayName: fontName))
                        return
                    }
                    
                    array.append((fontName: fontName, displayName: "\(familyName) \(lastName)"))
                }
            }
            
            return array
        }()
        
        return .optionsList(
            title: title,
            emptyTitle: emptyTitle,
            axis: .vertical,
            options: availableFonts.map { $0.displayName },
            selectedIndex: { availableFonts.firstIndex { $0.fontName == fontProvider()?.fontName } }
        ) {
            guard let newIndex = $0 else {
                return
            }
            
            let fontNames = availableFonts.map { $0.fontName }
            let fontName  = fontNames[newIndex]
            
            guard let pointSize = fontProvider()?.pointSize else {
                return
            }
            
            let newFont = UIFont(name: fontName, size: pointSize)
            
            handler(newFont)
        }
    }
    
    static func fontSizeStepper(
        title: String,
        fontProvider: @escaping FontProvider,
        handler: @escaping FontHandler
    ) -> AttributesInspectorSectionProperty {
        
        .cgFloatStepper(
            title: title,
            value: { fontProvider()?.pointSize ?? 0 },
            range: { 0...256 },
            stepValue: { 1 }
        ) { fontSize in
            
            let newFont = fontProvider()?.withSize(fontSize)
            
            handler(newFont)
        }
    }
    
}
