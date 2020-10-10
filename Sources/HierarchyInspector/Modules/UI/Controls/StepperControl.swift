//
//  StepperControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class StepperControl: BaseControl {
    // MARK: - Properties
    
    static let sharedDecimalNumberFormatter = NumberFormatter().then {
        $0.minimumFractionDigits = 2
        $0.numberStyle = .decimal
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
    
    private var isDecimalValue = true
    
    // MARK: - Components

    private lazy var stepperControl = UIStepper().then {
        $0.addTarget(self, action: #selector(step), for: .valueChanged)
    }
    
    private lazy var counterLabel = UILabel().then {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.font = titleLabel.font
        $0.textColor = tintColor
    }
    
    private var decimalFormatter: NumberFormatter {
        StepperControl.sharedDecimalNumberFormatter
    }
    
    // MARK: - Init
    
    convenience init(title: String?, value: Int, range: ClosedRange<Int>, stepValue: Int) {
        self.init(title: title, value: Double(value), range: Double(range.lowerBound)...Double(range.upperBound), stepValue: Double(stepValue))
        
        isDecimalValue = false
        
        updateCounterLabel()
    }
    
    init(title: String?, value: Double, range: ClosedRange<Double>, stepValue: Double) {
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

    @objc func step() {
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

