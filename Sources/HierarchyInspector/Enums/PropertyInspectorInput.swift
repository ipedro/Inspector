//
//  PropertyInspectorInput.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum PropertyInspectorInput {
    case doubleStepper(title: String, value: Double, range: ClosedRange<Double>, stepValue: Double, handler: ((Double) -> Void))
    
    case integerStepper(title: String, value: Int, range: ClosedRange<Int>, stepValue: Int, handler: ((Int) -> Void))
    
    case colorPicker(title: String, color: UIColor?, handler: ((UIColor?) -> Void))
    
    case toggleButton(title: String, isOn: Bool, handler: ((Bool) -> Void))
    
    case segmentedControl(title: String, items: [CustomStringConvertible], selectedSegmentIndex: Int?, handler: ((Int?) -> Void))
    
    case optionSelector(title: String, options: [CustomStringConvertible], selectedIndex: Int?, handler: ((Int?) -> Void))
}

extension PropertyInspectorInput: Hashable {
    var title: String {
        switch self {
        case let .doubleStepper(title, _, _, _, _),
             let .integerStepper(title, _, _, _, _),
             let .colorPicker(title, _, _),
             let .toggleButton(title, _, _),
             let .segmentedControl(title, _, _, _),
             let .optionSelector(title, _, _, _):
            return title
        }
    }
    
    static func == (lhs: PropertyInspectorInput, rhs: PropertyInspectorInput) -> Bool {
        lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        title.hash(into: &hasher)
    }
}
