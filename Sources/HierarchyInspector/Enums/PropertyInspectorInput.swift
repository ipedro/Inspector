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
    
    case toggleButton(title: String, isOn: Bool, handler: ((Bool) -> Void)?)
    
    case inlineTextOptions(title: String, texts: [CustomStringConvertible], selectedSegmentIndex: Int?, handler: ((Int?) -> Void)?)
    
    case inlineImageOptions(title: String, images: [UIImage], selectedSegmentIndex: Int?, handler: ((Int?) -> Void)?)
    
    case optionsList(title: String, options: [CustomStringConvertible], selectedIndex: Int?, handler: ((Int?) -> Void)?)
    
    case subSection(name: String)
    
    case separator(identifier: UUID)
    
    static let separator = PropertyInspectorInput.separator(identifier: UUID())
}

extension PropertyInspectorInput: Hashable {
    private var idenfitifer: String {
        switch self {
        case let .cgFloatStepper(title, _, _, _, _),
             let .integerStepper(title, _, _, _, _),
             let .colorPicker(title, _, _),
             let .toggleButton(title, _, _),
             let .inlineTextOptions(title, _, _, _),
             let .inlineImageOptions(title, _, _, _),
             let .optionsList(title, _, _, _),
             let .subSection(title):
            return title
            
        case let .separator(identifier):
            return identifier.uuidString
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
             .optionsList:
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
             .optionsList(_, _, _, .some):
            return true
            
        case .cgFloatStepper,
             .integerStepper,
             .colorPicker,
             .toggleButton,
             .inlineTextOptions,
             .inlineImageOptions,
             .optionsList,
             .subSection,
             .separator:
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
