//
//  LengthMeasurementView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 29.10.20.
//

import UIKit

final class LengthMeasurementView: BaseView {
    
    let axis: NSLayoutConstraint.Axis
    
    var color: UIColor
    
    var measurementName: String? {
        didSet {
            nameLabel.text     = measurementName
            nameLabel.isHidden = measurementName?.isEmpty != false
        }
    }
    
    private lazy var valueLabel = UILabel(
        .textStyle(.caption2),
        .textAlignment(.center),
        .textColor(color)
    )
    
    private lazy var nameLabel = UILabel(
        .text(measurementName),
        .textStyle(.caption2),
        .textAlignment(.center),
        .textColor(color),
        .viewOptions(.isHidden(measurementName?.isEmpty != false))
    )
    
    private lazy var arrowView = ArrowView(
        axis: axis,
        color: color,
        frame: bounds
    )
    
    private lazy var topAnchorConstraint = contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor)
    
    private lazy var leadingAnchorConstraint = contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
    
    init(axis: NSLayoutConstraint.Axis, color: UIColor, name: String? = nil, frame: CGRect = .zero) {
        self.axis = axis
        self.color = color
        self.measurementName = name
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        contentView.alignment = .center
        
        contentView.directionalLayoutMargins = .allMargins(2)
        
        contentView.spacing = ElementInspector.appearance.verticalMargins
        
        contentView.addArrangedSubview(valueLabel)
        
        contentView.addArrangedSubview(nameLabel)
        
        contentView.removeFromSuperview()
        
        installView(arrowView)
        
        contentView.removeFromSuperview()
        
        installView(contentView, .centerXY)

        topAnchorConstraint.isActive = true

        leadingAnchorConstraint.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch axis {
        case .vertical:
            valueLabel.text = frame.height.formattedString
            
        case .horizontal:
            valueLabel.text = frame.width.formattedString
            
        @unknown default:
            break
        }
        
        arrowView.gapSize = {
            guard nameLabel.isHidden else {
                return .zero
            }
            
            return contentView.frame.size
            
        }()
        
    }
}

fileprivate extension CGFloat {
    private static let numberFormatter = NumberFormatter(
        .numberStyle(.decimal)
    )
    
    var formattedString: String? {
        Self.numberFormatter.string(from: NSNumber(value: Float(self)))
    }
}
