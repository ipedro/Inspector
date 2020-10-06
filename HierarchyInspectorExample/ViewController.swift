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
        .controls,
        .buttons,
        .staticTexts + .images,
        .textViews + .textFields,
        .stackViews + .containerViews,
//        .activityIndicators,
//        .allViews
    ]
    
    var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme = .colorScheme { view in
        switch view {
        case is CustomButton:
            return .systemOrange
            
        default:
            return HierarchyInspector.ColorScheme.default.color(for: view)
        }
    }
    
    // MARK: - Components
    
    private lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var inspectBarButton: CustomButton!
    
    @IBOutlet var inspectButton: CustomButton!
    
    @IBOutlet var datePickerSegmentedControl: UISegmentedControl!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var textField: UITextField!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        scrollView.refreshControl = refreshControl
        
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
}

// MARK: - Actions

extension ViewController {

    @IBAction func changeDatePickerStyle(_ sender: UISegmentedControl) {
        guard let style = UIDatePickerStyle(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        
        datePicker.preferredDatePickerStyle = style
        
    }
    
    @IBAction func openInspector(_ sender: Any) {
        presentHierarchyInspector(animated: true)
    }
    
    @IBAction func rotateActivityIndicator(_ sender: UISlider) {
        let angle = (sender.value - 1) * .pi
        
        activityIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
    }
    
    @IBAction func toggleTextField(_ sender: UISwitch) {
        textField.isEnabled = sender.isOn
    }
    
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
    var inspectButtonFrame: CGRect {
        inspectButton.convert(inspectButton.bounds, to: scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var inspectBarButtonAlpha: CGFloat {
            let scrollRange = inspectButtonFrame.minY ... inspectButtonFrame.maxY
            
            guard scrollView.contentOffset.y >= scrollRange.lowerBound else {
                return 0
            }
            
            guard scrollView.contentOffset.y <= scrollRange.upperBound else {
                return 1
            }
            
            let delta = (scrollView.contentOffset.y - scrollRange.lowerBound) / (scrollRange.upperBound - scrollRange.lowerBound)
            let normalizedDelta = min(1, max(0, delta))
            let alpha = pow(normalizedDelta, 4)
            
            print("scroll delta: \(delta)\t|\t normalized delta: \(normalizedDelta)\t|\t alpha: \(alpha)")
            
            return alpha
        }
        
        inspectBarButton.alpha = inspectBarButtonAlpha
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

extension ViewController: HierarchyInspectorKeyCommandPresentable {
    
    override var keyCommands: [UIKeyCommand]? {
        hierarchyInspectorKeyCommands
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    var presentHirearchyInspectorKeyCommandSelector: Selector? {
        #selector(keyCommand(_:))
    }
    
    @objc func keyCommand(_ sender: Any) {
        hierarchyInspectorKeyCommandHandler(sender)
    }
}
