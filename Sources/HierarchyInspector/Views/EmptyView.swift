//
//  EmptyView.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

final class EmptyView: HighlightView {
    override init(
        frame: CGRect,
        name: String,
        colorScheme: @escaping ColorScheme = { _ in HierarchyInspector.configuration.appearane.emptyLayerColor },
        borderWidth: CGFloat = HierarchyInspector.configuration.appearane.emptyLayerBorderWidth
    ) {
        super.init(frame: frame, name: name, colorScheme: colorScheme, borderWidth: borderWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
