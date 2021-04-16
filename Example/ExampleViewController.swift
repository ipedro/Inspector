//
//  ExampleViewController.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import HierarchyInspector
import UIKit
import MapKit

// MARK: - Example Hiearchy Inspectable Elements

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

// MARK: - Example View Controller

class ExampleViewController: HierarchyInspectableViewController {
    // MARK: - HierarchyInspectableProtocol
    
    override var hierarchyInspectorElementLibraries: [HierarchyInspectorElementLibraryProtocol] {
        ExampleElementLibrary.allCases
    }
    
    override var hierarchyInspectorLayers: [ViewHierarchyLayer] {
        [
            .controls,
            .buttons,
            .staticTexts + .images,
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
    
    @IBOutlet weak var longTextLabel: UILabel!
    
    @IBOutlet weak var textStackView: UIStackView!
    
    @IBOutlet weak var switchTextField: UITextField!
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var mapView: MKMapView!
    
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