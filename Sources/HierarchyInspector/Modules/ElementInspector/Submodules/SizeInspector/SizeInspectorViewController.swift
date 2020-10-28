//
//  SizeInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit

final class SizeInspectorViewController: ElementInspectorPanelViewController {
    func calculatePreferredContentSize() -> CGSize {
        #warning("implement")
        
        return preferredContentSize
    }
    
    private lazy var viewCode = SizeInspectorViewCode()
    
    override func loadView() {
        view = viewCode
    }
}

final class SizeInspectorViewCode: BaseView {
    
    private lazy var verticalMeasurementView = MeasurementView(axis: .vertical, color: .cyan)
    
    private lazy var horizontalMeasurementView = MeasurementView(axis: .horizontal, color: .cyan)
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(verticalMeasurementView)
        
        verticalMeasurementView.installView(horizontalMeasurementView)
    }
}

final class MeasurementView: BaseView {
    
    let axis: NSLayoutConstraint.Axis
    
    var color: UIColor
    
    init(axis: NSLayoutConstraint.Axis, color: UIColor, frame: CGRect = .zero) {
        self.axis = axis
        self.color = color
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()

        isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        switch axis {
        case .vertical:
            IconKit.drawSizeArrowVertical(color: color, frame: rect)
            
        case .horizontal:
            IconKit.drawSizeArrowHorizontal(color: color, frame: rect)
            
        @unknown default:
            break
        }
    }
}
