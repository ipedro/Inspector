//
//  SegmentedControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol SegmentedControlDisplayable {
    var displayItem: Any { get }
}

extension String: SegmentedControlDisplayable {
    var displayItem: Any {
        self
    }
}

extension UIImage: SegmentedControlDisplayable {
    var displayItem: Any {
        self
    }
}

final class SegmentedControl: BaseFormControl {
    // MARK: - Properties
    
    let options: [SegmentedControlDisplayable]
    
    override var isEnabled: Bool {
        didSet {
            segmentedControl.isEnabled = isEnabled
        }
    }
    
    var selectedIndex: Int? {
        get {
            segmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment ? nil : segmentedControl.selectedSegmentIndex
        }
        set {
            guard let newValue = newValue else {
                segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
                return
            }
            
            segmentedControl.selectedSegmentIndex = newValue
        }
    }
    
    private lazy var segmentedControl = UISegmentedControl(items: options.map { $0.displayItem }).then {
        $0.addTarget(self, action: #selector(changeSegment), for: .valueChanged)
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            $0.selectedSegmentTintColor = ElementInspector.appearance.tintColor
            $0.setTitleTextAttributes([.foregroundColor: ElementInspector.appearance.textColor], for: .selected)
            $0.overrideUserInterfaceStyle = .dark
        }
        else {
            $0.tintColor = .systemPurple
        }
        #else
        $0.tintColor = .systemPurple
        #endif
    }
    
    // MARK: - Init
    
    init(title: String?, options: [SegmentedControlDisplayable], selectedIndex: Int?) {
        self.options = options
        
        super.init(title: title)
        
        self.selectedIndex = selectedIndex
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        axis = .vertical
        
        contentView.installView(segmentedControl)
    }

    @objc
    func changeSegment() {
        sendActions(for: .valueChanged)
    }
}