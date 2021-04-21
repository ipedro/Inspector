//
//  Mirror+AccessibilityIdentifiers.swift
//  HierarchyInspector
//
//

import UIKit

public extension Mirror {
    func subviewsAccessibilityIdentifiers(of type: Any.Type? = nil) {
        let type = type ?? subjectType

        for child in children {
            if
                let view = child.value as? UIView,
                view.accessibilityIdentifier.isNilOrEmpty,
                let identifier = child.label?
                    .replacingOccurrences(of: ".storage", with: "")
                    .replacingOccurrences(of: "$__lazy_storage_$_", with: "") {
                view.accessibilityIdentifier = "\(type).\(identifier)"

                print(String(describing: view.accessibilityIdentifier))
            }
        }
        
        if
            let superClassMirror = superclassMirror,
            superClassMirror.subjectType.self is AccessibilityIdentifiersProtocol.Type
        {
            superClassMirror.subviewsAccessibilityIdentifiers(of: type)
        }
    }
}
