//
//  PropertyInspectorUISwitchSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit


final class PropertyInspectorUISwitchSectionViewModel: PropertyInspectorSectionViewModelProtocol {
    
    private enum Property: CaseIterable {
        case title
        case style
        case isOn
        case onTintColor
        case thumbTintColor
    }
    
    private(set) weak var switchControl: UISwitch?
    
    init(switchControl: UISwitch) {
        self.switchControl = switchControl
    }
    
    private(set) lazy var title: String? = "Switch"
    
    
    private(set) lazy var propertyInpus: [PropertyInspectorInput] = Property.allCases.compactMap {
        guard let switchControl = switchControl else {
            return nil
        }

        switch $0 {
        case .title:
            #if swift(>=5.3)
            if #available(iOS 14.0, *) {
                return .optionsList(
                    title: "title",
                    options: [switchControl.title ?? "none"],
                    selectedIndex: 0,
                    handler: nil
                )
            }
            #endif
            return nil
            
        case .style:
            #if swift(>=5.3)
            if #available(iOS 14.0, *) {
                return .inlineTextOptions(
                    title: "style",
                    texts: UISwitch.Style.allCases,
                    selectedSegmentIndex: UISwitch.Style.allCases.firstIndex(of: switchControl.style),
                    handler: nil
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
