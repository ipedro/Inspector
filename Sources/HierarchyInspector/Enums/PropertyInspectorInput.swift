//
//  PropertyInspectorInput.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum PropertyInspectorInput {
    case cgFloatStepper(title: String, value: CGFloat, range: ClosedRange<CGFloat>, stepValue: CGFloat, handler: ((CGFloat) -> Void))
    
    case integerStepper(title: String, value: Int, range: ClosedRange<Int>, stepValue: Int, handler: ((Int) -> Void))
    
    case colorPicker(title: String, color: UIColor?, handler: ((UIColor?) -> Void))
    
    case toggleButton(title: String, isOn: Bool, handler: ((Bool) -> Void))
    
    case inlineOptions(title: String, items: [CustomStringConvertible], selectedSegmentIndex: Int?, handler: ((Int?) -> Void))
    
    case optionsList(title: String, options: [CustomStringConvertible], selectedIndex: Int?, handler: ((Int?) -> Void))
    
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
             let .inlineOptions(title, _, _, _),
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
             .inlineOptions,
             .optionsList:
            return true
            
        case .subSection,
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
