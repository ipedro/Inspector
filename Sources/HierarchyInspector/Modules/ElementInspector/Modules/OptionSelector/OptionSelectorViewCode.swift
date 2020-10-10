//
//  OptionSelectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class OptionSelectorViewCode: BaseView {
    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    private(set) lazy var pickerView = UIPickerView()
    
    override func setup() {
        super.setup()
        
        if #available(iOS 13.0, *) {
            backgroundColor = .tertiarySystemBackground
        }
        else {
            backgroundColor = .white
        }
        
        contentView.addArrangedSubview(pickerView)
    }
}
