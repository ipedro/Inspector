//
//  StepperControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class StepperControl: BaseFormControl {
    // MARK: - Properties
    
    static let sharedDecimalNumberFormatter = NumberFormatter().then {
        $0.minimumFractionDigits = 2
        $0.numberStyle = .decimal
    }
    
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
    
    let isDecimalValue: Bool
    
    // MARK: - Components

    private lazy var stepperControl = UIStepper().then {
        $0.addTarget(self, action: #selector(step), for: .valueChanged)
    }
    
    private lazy var counterLabel = UILabel().then {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.font = titleLabel.font?.withTraits(traits: .traitMonoSpace)
        $0.textColor = tintColor
    }
    
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

