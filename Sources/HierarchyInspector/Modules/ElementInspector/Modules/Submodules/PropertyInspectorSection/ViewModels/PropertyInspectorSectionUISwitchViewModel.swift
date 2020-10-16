//
//  PropertyInspectorSectionUISwitchViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class PropertyInspectorSectionUISwitchViewModel: PropertyInspectorSectionViewModelProtocol {
    
    private enum Property: CaseIterable {
        case title
        case preferredStyle
        case isOn
        case onTintColor
        case thumbTintColor
    }
    
    private(set) weak var switchControl: UISwitch?
    
    init(switchControl: UISwitch) {
        self.switchControl = switchControl
    }
    
    private(set) lazy var title: String? = "Switch"
    
    private(set) lazy var propertyInputs: [PropertyInspectorInput] = Property.allCases.compactMap {
        guard let switchControl = switchControl else {
            return nil
        }

        switch $0 {
        case .title:
            #if swift(>=5.3)
            if #available(iOS 14.0, *) {
                return .textInput(
                    title: "title",
                    value: switchControl.title,
                    placeholder: switchControl.title ?? "title"
                ) { title in
                    switchControl.title = title
                }
            }
            #endif
            return nil
            
        case .preferredStyle:
            #if swift(>=5.3)
            if #available(iOS 14.0, *) {
                return .inlineTextOptions(
                    title: "preferred style",
                    texts: UISwitch.Style.allCases,
                    selectedSegmentIndex: UISwitch.Style.allCases.firstIndex(of: switchControl.preferredStyle),
                    handler: {
                        guard let newIndex = $0 else {
                            return
                        }
                        
                        let preferredStyle = UISwitch.Style.allCases[newIndex]
                        
                        switchControl.preferredStyle = preferredStyle
                    }
                )
            }
            #endif
            return nil
                
        case .isOn:
            return .toggleButton(
                title: "state",
                isOn: switchControl.isOn
            ) { isOn in
                switchControl.setOn(isOn, animated: true)
                switchControl.sendActions(for: .valueChanged)
            }
                
        case .onTintColor:
            return .colorPicker(
                title: "on tint",
                color: switchControl.onTintColor
            ) { onTintColor in
                switchControl.onTintColor = onTintColor
            }
                
        case .thumbTintColor:
            return .colorPicker(
                title: "thumb tint",
                color: switchControl.thumbTintColor
            ) { thumbTintColor in
                switchControl.thumbTintColor = thumbTintColor
            }
            
        }
    }
}
