//
//  ViewController.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit
import HierarchyInspector

class ViewController: HierarchyInspectableViewController {
    // MARK: - HierarchyInspectorPresentable
    
    override var hierarchyInspectorLayers: [ViewHierarchyLayer] {
        [
            .controls,
            .buttons,
            .staticTexts + .images,
            .textViews + .textFields,
            .stackViews + .containerViews
        ]
    }
    
    override var hierarchyInspectorColorScheme: ViewHierarchyColorScheme {
        .colorScheme { view in
            switch view {
            case is CustomButton:
                return .systemPink
                
            default:
                return ViewHierarchyColorScheme.default.color(for: view)
            }
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
            datePickerSegmentedControl.insertSegment(
                withTitle: style.description,
                at: datePickerSegmentedControl.numberOfSegments,
                animated: false
            )
        }
        
        datePickerSegmentedControl.selectedSegmentIndex = 0
        datePicker.preferredDatePickerStyle = .automatic
    }
}

// MARK: - Actions

extension ViewController {

    @IBAction func changeDatePickerStyle(_ sender: UISegmentedControl) {
        guard let datePickerStyle = UIDatePickerStyle(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        
        if #available(iOS 14.0, *) {
            if
                datePicker.datePickerMode == .countDownTimer,
                datePickerStyle == .inline || datePickerStyle == .compact
            {
                datePicker.datePickerMode = .dateAndTime
            }
        }
        
        datePicker.preferredDatePickerStyle = datePickerStyle
        
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
    
    @objc
    func refresh() {
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

// MARK: - UIDatePickerStyle CaseIterable

extension UIDatePickerStyle: CaseIterable {
    public typealias AllCases = [UIDatePickerStyle]
    
    public static let allCases: [UIDatePickerStyle] = [
        .automatic,
        .wheels,
        .compact,
        .inline
    ]
}

// MARK: - UIDatePickerStyle CustomStringConvertible

extension UIDatePickerStyle: CustomStringConvertible {
    
    public var description: String {
        switch self {
        
        case .automatic:
            return "Automatic"
            
        case .wheels:
            return "Wheels"
        
        case .compact:
            return "Compact"
        
        case .inline:
            return "Inline"
            
        @unknown default:
            return "Unknown"
            
        }
    }
    
}
