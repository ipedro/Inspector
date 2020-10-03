//
//  ViewController.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit
import HierarchyInspector

class ViewController: UIViewController, HierarchyInspectorPresentable {
    
    var hierarchyInspectorViews: [HierarchyInspector.Layer : [View]] = [:]
    
    var hierarchyInspectorLayers: [HierarchyInspector.Layer] = [
        .controls,
        .containerViews,
        .stackViews,
        .textViews + .textFields, .textInputs,
        .staticTexts,
        .activityIndicators
    ]
    
    var hierarchyInspectorSnapshot: HierarchyInspector.ViewHierarchySnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func presentInspector(_ sender: Any) {
        presentHierarchyInspector(animated: true)
    }
    
}
