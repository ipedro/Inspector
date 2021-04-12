//
//  CustomButtonInspectableViewModel.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 12.04.21.
//

import UIKit
import HierarchyInspector

final class CustomButtonInspectableViewModel: HiearchyInspectableElementViewModelProtocol {
    var title: String = "Custom Button"
    
    let customButton: CustomButton
    
    init?(view: UIView) {
        guard let customButton = view as? CustomButton else {
            return nil
        }
        self.customButton = customButton
    }
    
    enum Properties: String, CaseIterable {
        case animateOnTouch = "Animate On Touch"
        case cornerRadius = "Corner Radius"
    }
    
    var properties: [HiearchyInspectableElementProperty] {
        Properties.allCases.map { property in
            switch property {
            case .animateOnTouch:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { self.customButton.animateOnTouch }
                ) { animateOnTouch in
                    self.customButton.animateOnTouch = animateOnTouch
                }
                
            case .cornerRadius:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { self.customButton.cornerRadius },
                    range: { 0...self.customButton.frame.height / 2 },
                    stepValue: { 1 }
                ) { cornerRadius in
                    self.customButton.cornerRadius = cornerRadius
                }
                
            }
            
        }
    }
}
