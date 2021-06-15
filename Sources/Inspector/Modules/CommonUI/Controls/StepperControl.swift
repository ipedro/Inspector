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
@_implementationOnly import UIKitOptions

final class StepperControl: BaseFormControl {
    // MARK: - Properties
    
    static let sharedDecimalNumberFormatter = NumberFormatter(
        .minimumFractionDigits(2),
        .numberStyle(.decimal)
    )
    
    override var isEnabled: Bool {
        didSet {
            stepperControl.isEnabled = isEnabled
        }
    }
    
    var value: Double {
        get {
            stepperControl.value
        }
        set {
            stepperControl.value = newValue
            updateCounterLabel()
        }
    }
    
    var range: ClosedRange<Double> {
        get {
            stepperControl.minimumValue...stepperControl.maximumValue
        }
        set {
            stepperControl.minimumValue = newValue.lowerBound
            stepperControl.maximumValue = newValue.upperBound
        }
    }
    
    var stepValue: Double {
        get {
            stepperControl.stepValue
        }
        set {
            stepperControl.stepValue = newValue
        }
    }
    
    let isDecimalValue: Bool
    
    // MARK: - Components

    private lazy var stepperControl = UIStepper().then {
        $0.addTarget(self, action: #selector(step), for: .valueChanged)
        
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            $0.overrideUserInterfaceStyle = .dark
        }
        #endif
    }
    
    private lazy var counterLabel = UILabel(
        .font(titleLabel.font!.withTraits(.traitMonoSpace)),
        .textColor(tintColor),
        .huggingPriority(.required, for: .horizontal)
    )
    
    private var decimalFormatter: NumberFormatter {
        StepperControl.sharedDecimalNumberFormatter
    }
    
    // MARK: - Init
    
    init(title: String?, value: Double, range: ClosedRange<Double>, stepValue: Double, isDecimalValue: Bool) {
        self.isDecimalValue = isDecimalValue
        
        super.init(title: title)
        
        self.stepperControl.maximumValue = range.upperBound
        
        self.stepperControl.minimumValue = range.lowerBound
        
        self.stepperControl.stepValue = stepValue
        
        self.value = value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(counterLabel)
        
        contentView.addArrangedSubview(stepperControl)
    }

    @objc
    func step() {
        updateCounterLabel()
        
        sendActions(for: .valueChanged)
    }
    
    private func updateCounterLabel() {
        guard isDecimalValue else {
            counterLabel.text = String(Int(stepperControl.value))
            return
        }
        
        counterLabel.text = decimalFormatter.string(from: NSNumber(value: stepperControl.value))
    }
}

