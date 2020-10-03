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
    
    private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(host: self)
    
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
    
    // MARK: - Components
    
    private lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var inspectBarButton: Button!
    
    @IBOutlet var inspectButton: Button!
    
    @IBOutlet var datePickerSegmentedControl: UISegmentedControl!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        scrollView.refreshControl = refreshControl
        
        inspectBarButton.alpha = 0
        
        if #available(iOS 13.4, *) {
            setupSegmentedControl()
        } else {
            datePickerSegmentedControl.removeSegment(at: 1, animated: false)
        }
    }
    
    func setupSegmentedControl() {
        datePickerSegmentedControl.removeAllSegments()
        
        UIDatePickerStyle.allCases.forEach { style in
            var title: String {
                switch style {
                case .automatic:
                    return "Automatic"
                    
                case .wheels:
                    return "Wheels"
                    
                case .compact:
                    return "Compact"
                    
                case .inline:
                    return "Inline"
                    
                @unknown default:
                    return "Unknown style"
                }
            }
            
            datePickerSegmentedControl.insertSegment(withTitle: title, at: datePickerSegmentedControl.numberOfSegments, animated: false)
        }
        
        datePickerSegmentedControl.selectedSegmentIndex = 0
        datePicker.preferredDatePickerStyle = .automatic
    }
        
    // MARK: - Actions

    @IBAction func changeDatePickerStyle(_ sender: UISegmentedControl) {
        guard let style = UIDatePickerStyle(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        
        datePicker.preferredDatePickerStyle = style
        
    }
    
    @IBAction func presentInspector(_ sender: Any) {
        presentHierarchyInspector(animated: true)
    }
    
    @IBAction func slider(_ sender: UISlider) {
        let angle = (sender.value - 1) * .pi
        
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
        let delta = (scrollView.contentOffset.y - inspectButton.frame.midY) / 100
        
        let alpha = min(1, max(0, delta))
        
        inspectBarButton.alpha = pow(alpha, 4)
    }
}

extension UIDatePickerStyle: CaseIterable {
    public static var allCases: [UIDatePickerStyle] {
        if #available(iOS 14.0, *) {
            return [.automatic, .wheels, .compact, .inline]
        } else {
            return [.automatic, .wheels, .compact]
        }
    }
    
    public typealias AllCases = [UIDatePickerStyle]
}
