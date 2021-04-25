//
//  ExampleElementLibrary.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 25.04.21.
//

import UIKit
import HierarchyInspector

enum ExampleElementLibrary: HierarchyInspectorElementLibraryProtocol, CaseIterable {
    case customButton
    
    var targetClass: AnyClass {
        switch self {
        case .customButton:
            return CustomButton.self
        }
    }
    
    func viewModel(with referenceView: UIView) -> HierarchyInspectorElementViewModelProtocol? {
        switch self {
        case .customButton:
            return CustomButtonInspectableViewModel(view: referenceView)
        }
    }
    
    func icon(with referenceView: UIView) -> UIImage? {
        switch self {
        case .customButton:
            return #imageLiteral(resourceName: "CustomButton_32")
        }
    }
}
