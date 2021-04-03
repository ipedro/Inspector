//
//  AttributesInspectorSectionProperty.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum AttributesInspectorSectionProperty {
    
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
                     options: [CustomStringConvertible],
                     selectedIndex: SelectionProvider,
                     handler: SelectionHandler?)
    
    case segmentedControl(title: String,
                          axis: NSLayoutConstraint.Axis = .vertical,
                          options: [SegmentedControlDisplayable],
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

extension AttributesInspectorSectionProperty {
    
    var isControl: Bool {
        switch self {
        
        case .stepper,
             .colorPicker,
             .toggleButton,
             .segmentedControl,
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
             .segmentedControl(_, _, _, _, .some),
             .optionsList(_, _, _, _, _, .some),
             .textField(_, _, _, .some),
             .textView(_, _, _, .some),
             .imagePicker(_, _, .some):
            return true
            
        case .stepper,
             .colorPicker,
             .toggleButton,
             .segmentedControl,
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
