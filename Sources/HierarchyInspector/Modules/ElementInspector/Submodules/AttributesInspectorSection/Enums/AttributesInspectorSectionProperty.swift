//
//  AttributesInspectorSectionProperty.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum AttributesInspectorSectionProperty {
    
    // Value providers
    typealias BoolProvider              = (() -> Bool)
    typealias DoubleProvider            = (() -> Double)
    typealias IntProvider               = (() -> Int?)
    typealias StringProvider            = (() -> String?)
    typealias ColorProvider             = (() -> UIColor?)
    typealias ImageProvider             = (() -> UIImage?)
    typealias ClosedRangeDoubleProvider = (() -> ClosedRange<Double>)
    
    // Value change handlers
    typealias StringHandler  = ((String?)  -> Void)
    typealias DoubleHandler  = ((Double)   -> Void)
    typealias ColorHandler   = ((UIColor?) -> Void)
    typealias ImageHandler   = ((UIImage?) -> Void)
    typealias BoolHandler    = ((Bool)     -> Void)
    typealias IntHandler     = ((Int?)     -> Void)
    
    // MARK: - Cases
    
    case stepper(title: String, value: DoubleProvider, range: ClosedRangeDoubleProvider, stepValue: DoubleProvider, isDecimalValue: Bool, handler: DoubleHandler?)
    
    case colorPicker(title: String, color: ColorProvider, handler: ColorHandler?)
    
    case imagePicker(title: String, image: ImageProvider, handler: ImageHandler?)
    
    case toggleButton(title: String, isOn: BoolProvider, handler: BoolHandler?)
    
    case segmentedControl(title: String, options: [SegmentedControlDisplayable], axis: NSLayoutConstraint.Axis = .vertical, selectedIndex: IntProvider, handler: IntHandler?)
    
    case optionsList(title: String, options: [CustomStringConvertible], selectedIndex: IntProvider, handler: IntHandler?)
    
    case textInput(title: String, value: StringProvider, placeholder: StringProvider, handler:StringHandler?)
    
    case subSection(name: String)
    
    case separator(identifier: UUID)
    
    static let separator = AttributesInspectorSectionProperty.separator(identifier: UUID())
    
}

// MARK: - Hashable

extension AttributesInspectorSectionProperty: Hashable {
    
    private var idenfitifer: String {
        String(describing: self)
    }
    
    var isControl: Bool {
        switch self {
        
        case .stepper,
             .colorPicker,
             .toggleButton,
             .segmentedControl,
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
        
        case .stepper(_, _, _, _, _, .some),
             .colorPicker(_, _, .some),
             .toggleButton(_, _, .some),
             .segmentedControl(_, _, _, _, .some),
             .optionsList(_, _, _, .some),
             .textInput(_, _, _, .some),
             .imagePicker(_, _, .some):
            return true
            
        case .stepper,
             .colorPicker,
             .toggleButton,
             .segmentedControl,
             .optionsList,
             .textInput,
             .subSection,
             .separator,
             .imagePicker:
            return false
            
        }
    }
    
    static func == (lhs: AttributesInspectorSectionProperty, rhs: AttributesInspectorSectionProperty) -> Bool {
        lhs.idenfitifer == rhs.idenfitifer
    }
    
    func hash(into hasher: inout Hasher) {
        idenfitifer.hash(into: &hasher)
    }
}

// MARK: - Stepper Helpers

extension AttributesInspectorSectionProperty {
    
    static func integerStepper(
        title: String,
        value: @escaping (() -> Int),
        range: @escaping (() -> ClosedRange<Int>),
        stepValue: @escaping (() -> Int),
        handler: ((Int) -> Void)?
    ) -> AttributesInspectorSectionProperty {
        .stepper(
            title: title,
            value: { Double(value()) },
            range: { Double(range().lowerBound)...Double(range().upperBound) },
            stepValue: { Double(stepValue()) },
            isDecimalValue: false
        ) { doubleValue in
            handler?(Int(doubleValue))
        }
    }
    
    static func cgFloatStepper(
        title: String,
        value: @escaping (() -> CGFloat),
        range: @escaping (() -> ClosedRange<CGFloat>),
        stepValue: @escaping (() -> CGFloat),
        handler: ((CGFloat) -> Void)?
    ) -> AttributesInspectorSectionProperty {
        .stepper(
            title: title,
            value: { Double(value()) },
            range: { Double(range().lowerBound)...Double(range().upperBound) },
            stepValue: { Double(stepValue()) },
            isDecimalValue: true
        ) { doubleValue in
            handler?(CGFloat(doubleValue))
        }
    }
    
    
    static func floatStepper(
        title: String,
        value: @escaping (() -> Float),
        range: @escaping (() -> ClosedRange<Float>),
        stepValue: @escaping (() -> Float),
        handler: ((Float) -> Void)?
    ) -> AttributesInspectorSectionProperty {
        .stepper(
            title: title,
            value: { Double(value()) },
            range: { Double(range().lowerBound)...Double(range().upperBound)} ,
            stepValue: { Double(stepValue()) },
            isDecimalValue: true
        ) { doubleValue in
            handler?(Float(doubleValue))
        }
    }
    
}

// MARK: - Font Helpers

extension AttributesInspectorSectionProperty {
    
    private typealias FontReference = (fontName: String, displayName: String)
    
    #warning("TODO: Add system font support in FontNamePicker")
    static func fontNamePicker(
        title: String = "font name",
        fontProvider: @escaping (() -> UIFont?),
        handler: @escaping (UIFont?) -> ()
    ) -> AttributesInspectorSectionProperty {
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
        title: String = "font size",
        fontProvider: @escaping (() -> UIFont?),
        handler: @escaping (UIFont?) -> ()
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
