//
//  AttributesInspectorSectionProperty+TextView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.12.20.
//

import UIKit

extension AttributesInspectorSectionProperty {
    
    static func dataDetectorType(
        textView: UITextView,
        dataDetectorType: UIDataDetectorTypes
    ) -> AttributesInspectorSectionProperty {
        
        .toggleButton(
            title: dataDetectorType.description,
            isOn: { textView.dataDetectorTypes.contains(dataDetectorType) }
        ) { isOn in
            
            var dataDetectorTypes: UIDataDetectorTypes? {
                
                var dataDetectors = textView.dataDetectorTypes
                
                switch isOn {
                case true:
                    _ = dataDetectors.insert(dataDetectorType).memberAfterInsert
                    
                case false:
                    dataDetectors.remove(dataDetectorType)
                }
                
                return dataDetectors
            }
                
            let newDataDetectorTypes = dataDetectorTypes ?? []
            
            textView.dataDetectorTypes = newDataDetectorTypes
        }
        
    }
    
}
