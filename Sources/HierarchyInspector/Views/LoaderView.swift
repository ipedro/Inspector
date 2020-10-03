//
//  LoaderView.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

final class LoaderView: InternalView {
    // MARK: - Components
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    private lazy var contentView = InternalView(frame: frame)
    
    private lazy var colorScheme: ColorScheme = .colorScheme { _ in .systemBlue }
    
    // MARK: - Init
    
    private init() {
        
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    func setup() {
        backgroundColor = .systemTeal
        
        layer.cornerRadius = 12
        
    }
    
    func addInspectorViews() {
        rawViewHierarchy.forEach { element in
            element.layer.cornerRadius = 6
            
            let inspectorView = WireframeView(frame: element.bounds, color: .white)
            
            element.installView(inspectorView, position: .bottom)
        }
        
        let inspectorView = HighlightView(frame: bounds, name: className, colorScheme: colorScheme)
        
        installView(inspectorView, position: .top)
        
    }
}

// MARK: - Loader Pool Management

extension LoaderView {
    
    static var sharedPool: [UIView: LoaderView] = [:]
    
    static func dequeueLoaderView(for presenter: LoaderViewPresentable) -> LoaderView {
        guard let loaderView = sharedPool[presenter] else {
            
            let loaderView = LoaderView()
            
            sharedPool[presenter] = loaderView
            
            return loaderView
        }
        
        return loaderView
    }
    
}
