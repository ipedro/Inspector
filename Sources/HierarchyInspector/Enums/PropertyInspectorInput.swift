//
//  PropertyInspectorInput.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum PropertyInspectorInput {
    case cgFloatStepper(title: String, value: CGFloat, range: ClosedRange<CGFloat>, stepValue: CGFloat, handler: ((CGFloat) -> Void)?)
    
    case integerStepper(title: String, value: Int, range: ClosedRange<Int>, stepValue: Int, handler: ((Int) -> Void)?)
    
    case colorPicker(title: String, color: UIColor?, handler: ((UIColor?) -> Void)?)
    
    case imagePicker(title: String, image: UIImage?, handler: ((UIImage?) -> Void)?)
    
    case toggleButton(title: String, isOn: Bool, handler: ((Bool) -> Void)?)
    
    case inlineTextOptions(title: String, texts: [CustomStringConvertible], selectedSegmentIndex: Int?, handler: ((Int?) -> Void)?)
    
    case inlineImageOptions(title: String, images: [UIImage], selectedSegmentIndex: Int?, handler: ((Int?) -> Void)?)
    
    case optionsList(title: String, options: [CustomStringConvertible], selectedIndex: Int?, handler: ((Int?) -> Void)?)
    
    case textInput(title: String, value: String?, placeholder: String?, handler:((String?) -> Void)?)
    
    case subSection(name: String)
    
    case separator(identifier: UUID)
    
    static let separator = PropertyInspectorInput.separator(identifier: UUID())
}

extension PropertyInspectorInput: Hashable {
    private var idenfitifer: String {
        switch self {
        
        case let .separator(identifier):
            return identifier.uuidString
        
        case .cgFloatStepper,
             .integerStepper,
             .colorPicker,
             .toggleButton,
             .inlineTextOptions,
             .inlineImageOptions,
             .optionsList,
             .textInput,
             .subSection,
             .imagePicker:
            return String(describing: self)
            
        }
    }
    
    var isControl: Bool {
        switch self {
        
        case .cgFloatStepper,
             .integerStepper,
             .colorPicker,
             .toggleButton,
             .inlineTextOptions,
             .inlineImageOptions,
             .optionsList,
             .textInput,
             .imagePicker:
            return true
            
        case .subSection,
             .separator:
            return false
            
        }
    }
    
    var hasHandler: Bool {
        switch self {
        
        case .cgFloatStepper(_, _, _, _, .some),
             .integerStepper(_, _, _, _, .some),
             .colorPicker(_, _, .some),
             .toggleButton(_, _, .some),
             .inlineTextOptions(_, _, _, .some),
             .inlineImageOptions(_, _, _, .some),
             .optionsList(_, _, _, .some),
             .textInput(_, _, _, .some),
             .imagePicker(_, _, .some):
            return true
            
        case .cgFloatStepper,
             .integerStepper,
             .colorPicker,
             .toggleButton,
             .inlineTextOptions,
             .inlineImageOptions,
             .optionsList,
             .textInput,
             .subSection,
             .separator,
             .imagePicker:
            return false
            
        }
    }
    
    static func == (lhs: PropertyInspectorInput, rhs: PropertyInspectorInput) -> Bool {
        lhs.idenfitifer == rhs.idenfitifer
    }
    
    func hash(into hasher: inout Hasher) {
        idenfitifer.hash(into: &hasher)
    }
}


extension PropertyInspectorInput {
    
    private typealias FontReference = (fontName: String, displayName: String)
    
    #warning("TODO: Add system font support in FontNamePicker")
    static func fontNamePicker(title: String = "font name", fontProvider: @escaping (() -> UIFont?), handler: @escaping (UIFont?) -> ()) -> PropertyInspectorInput {
        let availableFonts: [FontReference] = {
            
            var array = [FontReference("", "—")]
            
            UIFont.familyNames.forEach { familyName in
                
                let familyNames = UIFont.fontNames(forFamilyName: familyName)
                
                if familyNames.count == 1, let fontName = familyNames.first {
                    array.append((fontName: fontName, displayName: familyName))
                    return
                }
                
                familyNames.forEach { fontName in
                    guard
                        let lastName = fontName.split(separator: "-").last,
                        lastName.replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(familyName.replacingOccurrences(of: " ", with: "")) != .orderedSame
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
            options: availableFonts.map { $0.displayName },
            selectedIndex: availableFonts.firstIndex { $0.fontName == fontProvider()?.fontName }
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
    
    static func fontSizeStepper(title: String = "font size", fontProvider: @escaping (() -> UIFont?), handler: @escaping (UIFont?) -> ()) -> PropertyInspectorInput {
        .cgFloatStepper(
            title: title,
            value: fontProvider()?.pointSize ?? 0,
            range: 0...256,
            stepValue: 1
        ) { fontSize in
            
            let newFont = fontProvider()?.withSize(fontSize)
            
            handler(newFont)
        }
    }
}
