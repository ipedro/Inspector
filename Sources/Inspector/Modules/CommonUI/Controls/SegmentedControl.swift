//  Copyright (c) 2021 Pedro Almeida
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

final class SegmentedControl: BaseFormControl {
    // MARK: - Properties
    
    let options: [Any]
    
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
    
    private lazy var segmentedControl = UISegmentedControl(items: options).then {
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
    
    init(title: String?, images: [UIImage], selectedIndex: Int?) {
        self.options = images
        
        super.init(title: title)
        
        self.selectedIndex = selectedIndex
    }
    
    init(title: String?, texts: [String], selectedIndex: Int?) {
        self.options = texts
        
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
