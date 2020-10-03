//
//  EmptyView.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

final class EmptyView: HighlightView {
    static let defaultColorScheme: ColorScheme = .colorScheme { _ in HierarchyInspector.configuration.appearance.emptyLayerColor }
    
    override init(
        frame: CGRect,
        name: String,
        colorScheme: ColorScheme = defaultColorScheme,
        borderWidth: CGFloat = HierarchyInspector.configuration.appearance.emptyLayerBorderWidth
    ) {
        super.init(frame: frame, name: name, colorScheme: colorScheme, borderWidth: borderWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
