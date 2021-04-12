//
//  ViewController.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit
import HierarchyInspector

// MARK: - Example Hiearchy Inspectable Elements

enum MyCustomHierarchyInspectableElements: HierarchyInspectableElementProtocol, CaseIterable {
    case customButton
    
    var targetClass: AnyClass {
        switch self {
        case .customButton:
            return CustomButton.self
        }
    }
    
    func viewModel(with referenceView: UIView) -> HierarchyInspectableElementViewModelProtocol? {
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

// MARK: - Example Inspectable View Controller

class ViewController: HierarchyInspectableViewController {
    // MARK: - HierarchyInspectableProtocol
    
    override var hierarchyInspectorElements: [HierarchyInspectableElementProtocol] {
        MyCustomHierarchyInspectableElements.allCases
    }
    
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
    
    lazy var refreshControl = UIRefreshControl()
    
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
