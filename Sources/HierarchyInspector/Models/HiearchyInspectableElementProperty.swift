//
//  HiearchyInspectableElementProperty.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

public enum HiearchyInspectableElementProperty {
    
    case colorPicker(title: String,
                     color: ColorProvider,
                     handler: ColorHandler?)
    
    case group(title: String)
    
    case imagePicker(title: String,
                     image: ImageProvider,
                     handler: ImageHandler?)
    
    case optionsList(title: String,
                     emptyTitle: String = "Unspecified",
                     axis: NSLayoutConstraint.Axis = .horizontal,
                     options: [String],
                     selectedIndex: SelectionProvider,
                     handler: SelectionHandler?)
    
    case textButtonGroup(title: String,
                         axis: NSLayoutConstraint.Axis = .vertical,
                         texts: [String],
                         selectedIndex: SelectionProvider,
                         handler: SelectionHandler?)
    
    case imageButtonGroup(title: String,
                          axis: NSLayoutConstraint.Axis = .vertical,
                          images: [UIImage],
                          selectedIndex: SelectionProvider,
                          handler: SelectionHandler?)
    
    case separator(title: String)
    
    case stepper(title: String,
                 value: DoubleProvider,
                 range: DoubleClosedRangeProvider,
                 stepValue: DoubleProvider,
                 isDecimalValue: Bool,
                 handler: DoubleHandler?)
    
    case textField(title: String,
                   placeholder: StringProvider,
                   value: StringProvider,
                   handler:StringHandler?)
    
    case textView(title: String,
                  placeholder: StringProvider,
                  value: StringProvider,
                  handler:StringHandler?)
    
    case toggleButton(title: String,
                      isOn: BoolProvider,
                      handler: BoolHandler?)
    
}

extension HiearchyInspectableElementProperty {
    
    var isControl: Bool {
        switch self {
        
        case .stepper,
             .colorPicker,
             .toggleButton,
             .textButtonGroup,
             .imageButtonGroup,
             .optionsList,
             .textField,
             .textView,
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
             .textButtonGroup(_, _, _, _, .some),
             .imageButtonGroup(_, _, _, _, .some),
             .optionsList(_, _, _, _, _, .some),
             .textField(_, _, _, .some),
             .textView(_, _, _, .some),
             .imagePicker(_, _, .some):
            return true
            
        case .stepper,
             .colorPicker,
             .toggleButton,
             .textButtonGroup,
             .imageButtonGroup,
             .optionsList,
             .textField,
             .textView,
             .group,
             .separator,
             .imagePicker:
            return false
            
        }
    }
    
}

// MARK: - Value Handlers

public extension HiearchyInspectableElementProperty {
    typealias BoolHandler      = ((Bool)     -> Void)
    typealias CGFloatHandler   = ((CGFloat)  -> Void)
    typealias ColorHandler     = ((UIColor?) -> Void)
    typealias DoubleHandler    = ((Double)   -> Void)
    typealias FloatHandler     = ((Float)    -> Void)
    typealias FontHandler      = ((UIFont?)  -> Void)
    typealias ImageHandler     = ((UIImage?) -> Void)
    typealias IntHandler       = ((Int)      -> Void)
    typealias SelectionHandler = ((Int?)     -> Void)
    typealias StringHandler    = ((String?)  -> Void)
}

// MARK: - Value Providers

public extension HiearchyInspectableElementProperty {
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
}