//
//  PropertyInspectorSectionUIActivityIndicatorViewViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class PropertyInspectorSectionUIActivityIndicatorViewViewModel: PropertyInspectorSectionViewModelProtocol {
    
    enum Property: CaseIterable {
        case style
        case color
        case groupBehavior
        case isAnimating
        case hidesWhenStopped
    }
    
    private(set) weak var activityIndicatorView: UIActivityIndicatorView?
    
    init(activityIndicatorView: UIActivityIndicatorView) {
        self.activityIndicatorView = activityIndicatorView
    }
    
    let title = "Activity Indicator"
    
    private(set) lazy var properties: [PropertyInspectorSectionProperty] = Property.allCases.compactMap {
        guard let activityIndicatorView = activityIndicatorView else {
            return nil
        }

        switch $0 {
        case .style:
            return .optionsList(
                title: "style",
                options: UIActivityIndicatorView.Style.allCases,
                selectedIndex: UIActivityIndicatorView.Style.allCases.firstIndex(of: activityIndicatorView.style)
            ) {
                guard let newIndex = $0 else {
                    return
                }
                
                activityIndicatorView.style = UIActivityIndicatorView.Style.allCases[newIndex]
            }
        case .color:
            return .colorPicker(
                title: "color",
                color: activityIndicatorView.color
            ) {
                guard let color = $0 else {
                    return
                }
                
                activityIndicatorView.color = color
            }
            
        case .groupBehavior:
            return .subSection(name: "Behavior")
            
        case .isAnimating:
            return .toggleButton(
                title: "animating",
                isOn: activityIndicatorView.isAnimating
            ) { isAnimating in
                
                switch isAnimating {
                    case true:
                        activityIndicatorView.startAnimating()
                        
                    case false:
                        activityIndicatorView.stopAnimating()
                }
            }
            
        case .hidesWhenStopped:
            return .toggleButton(
                title: "hides when stopped",
                isOn: activityIndicatorView.hidesWhenStopped
            ) { hidesWhenStopped in
                activityIndicatorView.hidesWhenStopped = hidesWhenStopped
            }
            
        }
        
    }
}
