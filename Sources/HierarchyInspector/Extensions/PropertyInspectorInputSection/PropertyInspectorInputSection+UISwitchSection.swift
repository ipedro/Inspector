//
//  PropertyInspectorInputSection+UISwitchSection.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

private enum UISwitchProperty: CaseIterable {
    case title
    case style
    case isOn
    case onTintColor
    case thumbTintColor
}

extension PropertyInspectorInputSection {
    static func UISwitchSection(switchControl: UISwitch?) -> PropertyInspectorInputSection {
        PropertyInspectorInputSection(title: "Switch", propertyInpus: UISwitchProperty.allCases.compactMap {
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
        })
    }
}

#if swift(>=5.3)
@available(iOS 14.0, *)
extension UISwitch.Style: CaseIterable {
    public typealias AllCases = [UISwitch.Style]
    
    public static let allCases: [UISwitch.Style] = [
        .automatic,
        .checkbox,
        .sliding
    ]
}

@available(iOS 14.0, *)
extension UISwitch.Style: CustomStringConvertible {
    public var description: String {
        switch self {
        case .automatic:
            return "automatic"
            
        case .checkbox:
            return "checkbox"
            
        case .sliding:
            return "sliding"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
#endif

