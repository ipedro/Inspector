//
//  ViewController.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit
import HierarchyInspector

class ViewController: UIViewController, HierarchyInspectorPresentable {
    
    var hierarchyInspectorViews: [HierarchyInspector.Layer: [HierarchyInspectorView]] = [:]
    
    var hierarchyInspectorLayers: [HierarchyInspector.Layer] = [
        .controls - .buttons,
        .buttons,
        .stackViews + .containerViews,
        .textViews + .textFields,
        .staticTexts,
        .activityIndicators,
        .maps
    ]
    
    var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme = .colorScheme { view in
        switch view {
        case is Button:
            return .systemYellow
            
        default:
            return HierarchyInspector.ColorScheme.default.color(for: view)
        }
    }
    
    var hierarchyInspectorSnapshot: HierarchyInspector.ViewHierarchySnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func presentInspector(_ sender: Any) {
        presentHierarchyInspector(animated: true)
    }
    
}
