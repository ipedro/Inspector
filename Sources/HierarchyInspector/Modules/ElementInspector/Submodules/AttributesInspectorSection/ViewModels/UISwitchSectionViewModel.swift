//
//  UISwitchSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {
        
    final class UISwitchSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        private enum Property: String, CaseIterable {
            case title          = "Title"
            case preferredStyle = "Preferred Style"
            case isOn           = "State"
            case onTintColor    = "On Tint"
            case thumbTintColor = "Thumb Tint"
        }
        
        let title = "Switch"
        
        private(set) weak var switchControl: UISwitch?
        
        init?(view: UIView) {
            guard let switchControl = view as? UISwitch else {
                return nil
            }
            
            self.switchControl = switchControl
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let switchControl = switchControl else {
                return nil
            }

            switch property {
            case .title:
                #if swift(>=5.3)
                if #available(iOS 14.0, *) {
                    return .textField(
                        title: property.rawValue,
                        value: { switchControl.title },
                        placeholder: { switchControl.title.isNilOrEmpty ? property.rawValue : switchControl.title }
                    ) { title in
                        switchControl.title = title
                    }
                }
                #endif
                return nil
                
            case .preferredStyle:
                #if swift(>=5.3)
                if #available(iOS 14.0, *) {
                    return .segmentedControl(
                        title: property.rawValue,
                        options: UISwitch.Style.allCases,
                        selectedIndex: { UISwitch.Style.allCases.firstIndex(of: switchControl.preferredStyle) },
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
                    title: property.rawValue,
                    isOn: { switchControl.isOn }
                ) { isOn in
                    switchControl.setOn(isOn, animated: true)
                    switchControl.sendActions(for: .valueChanged)
                }
                    
            case .onTintColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { switchControl.onTintColor }
                ) { onTintColor in
                    switchControl.onTintColor = onTintColor
                }
                    
            case .thumbTintColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { switchControl.thumbTintColor }
                ) { thumbTintColor in
                    switchControl.thumbTintColor = thumbTintColor
                }
                
            }
        }
    }

}
