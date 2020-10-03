//
//  WireframeView.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

final class WireframeView: View {
    override init(
        frame: CGRect,
        color: UIColor = HierarchyInspector.configuration.appearane.wireframeLayerColor,
        borderWidth: CGFloat = HierarchyInspector.configuration.appearane.wireframeLayerBorderWidth
    ) {
        super.init(frame: frame, color: color, borderWidth: borderWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
