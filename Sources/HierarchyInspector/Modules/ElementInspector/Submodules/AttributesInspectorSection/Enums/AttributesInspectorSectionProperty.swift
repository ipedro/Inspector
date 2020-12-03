//
//  AttributesInspectorSectionProperty.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum AttributesInspectorSectionProperty {
    
    // MARK: - Value providers
    
    typealias BoolProvider               = (() -> Bool)
    typealias CGFloatClosedRangeProvider = (() -> ClosedRange<CGFloat>)
    typealias CGFloatProvider            = (() -> CGFloat)
    typealias ColorProvider              = (() -> UIColor?)
    typealias DoubleClosedRangeProvider  = (() -> ClosedRange<Double>)
    typealias DoubleProvider             = (() -> Double)
    typealias FloatClosedRangeProvider   = (() -> ClosedRange<Float>)
    typealias FloatProvider              = (() -> Float)
    typealias FontProvider               = (() -> UIFont?)
    typealias ImageProvider              = (() -> UIImage?)
    typealias IntClosedRangeProvider     = (() -> ClosedRange<Int>)
    typealias IntProvider                = (() -> Int)
    typealias SelectionProvider          = (() -> Int?)
    typealias StringProvider             = (() -> String?)
    
    // MARK: - Value change handlers
    
    typealias BoolHandler                = ((Bool)     -> Void)
    typealias CGFloatHandler             = ((CGFloat)  -> Void)
    typealias ColorHandler               = ((UIColor?) -> Void)
    typealias DoubleHandler              = ((Double)   -> Void)
    typealias FloatHandler               = ((Float)    -> Void)
    typealias FontHandler                = ((UIFont?)  -> Void)
    typealias ImageHandler               = ((UIImage?) -> Void)
    typealias IntHandler                 = ((Int)      -> Void)
    typealias SelectionHandler           = ((Int?)     -> Void)
    typealias StringHandler              = ((String?)  -> Void)
    
    // MARK: - Cases
    
    case colorPicker(title: String, color: ColorProvider, handler: ColorHandler?)
    
    case group(title: String)
    
    case imagePicker(title: String, image: ImageProvider, handler: ImageHandler?)
    
    case optionsList(title: String, options: [CustomStringConvertible], axis: NSLayoutConstraint.Axis = .horizontal, emptyTitle: String = "Unspecified", selectedIndex: SelectionProvider, handler: SelectionHandler?)
    
    case segmentedControl(title: String, options: [SegmentedControlDisplayable], axis: NSLayoutConstraint.Axis = .vertical, selectedIndex: SelectionProvider, handler: SelectionHandler?)
    
    case separator(title: String)
    
    case stepper(title: String, value: DoubleProvider, range: DoubleClosedRangeProvider, stepValue: DoubleProvider, isDecimalValue: Bool, handler: DoubleHandler?)
    
    case textField(title: String, value: StringProvider, placeholder: StringProvider, handler:StringHandler?)
    
    case toggleButton(title: String, isOn: BoolProvider, handler: BoolHandler?)
    
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
             .textField,
             .imagePicker:
            return true
            
        case .group,
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
             .optionsList(_, _, _, _, _, .some),
             .textField(_, _, _, .some),
             .imagePicker(_, _, .some):
            return true
            
        case .stepper,
             .colorPicker,
             .toggleButton,
             .segmentedControl,
             .optionsList,
             .textField,
             .group,
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
        value: @escaping IntProvider,
        range: @escaping IntClosedRangeProvider,
        stepValue: @escaping IntProvider,
        handler: IntHandler?
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
        value: @escaping CGFloatProvider,
        range: @escaping CGFloatClosedRangeProvider,
        stepValue: @escaping CGFloatProvider,
        handler: CGFloatHandler?
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
            options: availableFonts.map { $0.displayName },
            axis: .vertical,
            emptyTitle: emptyTitle,
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

// MARK: - Data Detector Types

extension AttributesInspectorSectionProperty {
    
    static func dataDetectorType(
        textView: UITextView,
        dataDetectorType: UIDataDetectorTypes
    ) -> AttributesInspectorSectionProperty {
        
        .toggleButton(
            title: dataDetectorType.description,
            isOn: { textView.dataDetectorTypes.contains(dataDetectorType) }
        ) { isOn in
            
            var dataDetectorTypes: UIDataDetectorTypes? {
                
                var dataDetectors = textView.dataDetectorTypes
                
                switch isOn {
                case true:
                    _ = dataDetectors.insert(dataDetectorType).memberAfterInsert
                    
                case false:
                    dataDetectors.remove(dataDetectorType)
                }
                
                return dataDetectors
            }
                
            let newDataDetectorTypes = dataDetectorTypes ?? []
            
            textView.dataDetectorTypes = newDataDetectorTypes
        }
        
    }
    
}
