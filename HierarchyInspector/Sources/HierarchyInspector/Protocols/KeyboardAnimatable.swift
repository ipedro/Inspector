//
//  KeyboardAnimatable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.04.21.
//

import UIKit

protocol KeyboardAnimatable: UIViewController {}

struct KeyboardAnimationProperties {
    let duration: TimeInterval
    let keyboardFrame: CGRect
    let curveValue: Int
    let curve: UIView.AnimationCurve
}

extension KeyboardAnimatable {
    var durationKey: String { UIResponder.keyboardAnimationDurationUserInfoKey }
    
    var frameKey: String { UIResponder.keyboardFrameEndUserInfoKey }
    
    var curveKey: String { UIResponder.keyboardAnimationCurveUserInfoKey }
    
    var keyboardIsLocalKey: String { UIResponder.keyboardIsLocalUserInfoKey }
    
    func animateWithKeyboard(notification: Notification, animations: @escaping ((_ properties: KeyboardAnimationProperties) -> Void)) {
        guard
            let userInfo = notification.userInfo,
            userInfo[keyboardIsLocalKey] as? Bool == true,
            let duration = userInfo[durationKey] as? Double,
            let keyboardFrame = userInfo[frameKey] as? CGRect,
            let curveValue = userInfo[curveKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: curveValue)
        else {
            return
        }
        
        let properties = KeyboardAnimationProperties(
            duration: duration,
            keyboardFrame: keyboardFrame,
            curveValue: curveValue,
            curve: curve
        )
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            animations(properties)
            
            self.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
}
