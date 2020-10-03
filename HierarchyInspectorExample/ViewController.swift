//
//  ViewController.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit
import HierarchyInspector

class ViewController: UIViewController, HierarchyInspectorPresentable {
    // MARK: - HierarchyInspectorPresentable
    
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
    
    // MARK: - Components
    
    private lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var inspectBarButton: Button!
    
    @IBOutlet var inspectButton: Button!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        scrollView.refreshControl = refreshControl
        
        inspectBarButton.alpha = 0
    }
    
    // MARK: - Actions

    @IBAction func presentInspector(_ sender: Any) {
        presentHierarchyInspector(animated: true)
    }
    
    @IBAction func slider(_ sender: UISlider) {
        let angle = sender.value * .pi
        
        activityIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
    }
    
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.refreshControl.endRefreshing()
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        inspectBarButton.alpha = min(1, max(0, (scrollView.contentOffset.y - inspectButton.frame.maxY - (inspectButton.frame.height / 2)) / 100))
    }
}
