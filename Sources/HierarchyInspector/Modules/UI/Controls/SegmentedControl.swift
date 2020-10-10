//
//  SegmentedControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class SegmentedControl: BaseControl {
    // MARK: - Properties
    
    let options: [CustomStringConvertible]
    
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
    
    private lazy var segmentedControl = UISegmentedControl(
        items: options.map { $0.description.localizedCapitalized }
    ).then {
        $0.addTarget(self, action: #selector(changeSegment), for: .valueChanged)
    }
    
    // MARK: - Init
    
    init(title: String?, items: [CustomStringConvertible], selectedSegmentIndex: Int?) {
        self.options = items
        
        super.init(title: title)
        
        self.selectedIndex = selectedSegmentIndex
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        axis = .vertical
        
        contentView.installView(segmentedControl)
    }

    @objc func changeSegment() {
        sendActions(for: .valueChanged)
    }
}
