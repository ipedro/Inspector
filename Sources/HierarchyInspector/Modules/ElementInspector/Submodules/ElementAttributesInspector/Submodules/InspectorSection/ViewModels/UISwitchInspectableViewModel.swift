//
//  UISwitchSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIKitElementLibrary {
        
    final class UISwitchInspectableViewModel: HierarchyInspectorElementViewModelProtocol {
        
        private enum Property: String, Swift.CaseIterable {
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
        
        private(set) lazy var properties: [HiearchyInspectableElementProperty] = Property.allCases.compactMap { property in
            guard let switchControl = switchControl else {
                return nil
            }

            switch property {
            case .title:
                #if swift(>=5.3)
                if #available(iOS 14.0, *) {
                    return .textField(
                        title: property.rawValue,
                        placeholder: { switchControl.title.isNilOrEmpty ? property.rawValue : switchControl.title },
                        value: { switchControl.title }
                    ) { title in
                        switchControl.title = title
                    }
                }
                #endif
                return nil
                
            case .preferredStyle:
                #if swift(>=5.3)
                if #available(iOS 14.0, *) {
                    return .textButtonGroup(
                        title: property.rawValue,
                        texts: UISwitch.Style.allCases.map { $0.description },
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
