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

final class LengthMeasurementView: BaseView {
    let axis: NSLayoutConstraint.Axis
    
    var color: UIColor
    
    var measurementName: String? {
        didSet {
            nameLabel.text = measurementName
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
        measurementName = name
        
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        contentView.alignment = .center
        
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(insets: 2)
        
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

private extension CGFloat {
    private static let numberFormatter = NumberFormatter(
        .numberStyle(.decimal)
    )
    
    var formattedString: String? {
        Self.numberFormatter.string(from: NSNumber(value: Float(self)))
    }
}
