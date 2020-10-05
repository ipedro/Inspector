//
//  WireframeView.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

final class WireframeView: LayerView {
    override init(
        frame: CGRect,
        reference: ViewHierarchyReference,
        color: UIColor = HierarchyInspector.configuration.appearance.wireframeLayerColor,
        borderWidth: CGFloat = HierarchyInspector.configuration.appearance.wireframeLayerBorderWidth
    ) {
        super.init(frame: frame, reference: reference, color: color, borderWidth: borderWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
