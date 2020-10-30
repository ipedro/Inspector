//
//  UIActivityIndicatorViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {
    
    final class UIActivityIndicatorViewSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: String, CaseIterable {
            case style            = "Style"
            case color            = "Color"
            case groupBehavior    = "Behavior"
            case isAnimating      = "Animating"
            case hidesWhenStopped = "Hides When Stopped"
        }
        
        let title = "Activity Indicator"
        
        private(set) weak var activityIndicatorView: UIActivityIndicatorView?
        
        init?(view: UIView) {
            guard let activityIndicatorView = view as? UIActivityIndicatorView else {
                return nil
            }
            
            self.activityIndicatorView = activityIndicatorView
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let activityIndicatorView = activityIndicatorView else {
                return nil
            }

            switch property {
            case .style:
                return .optionsList(
                    title: property.rawValue,
                    options: UIActivityIndicatorView.Style.allCases,
                    selectedIndex: { UIActivityIndicatorView.Style.allCases.firstIndex(of: activityIndicatorView.style) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let style = UIActivityIndicatorView.Style.allCases[newIndex]
                        
                    activityIndicatorView.style = style
                }
            case .color:
                return .colorPicker(
                    title: property.rawValue,
                    color: { activityIndicatorView.color }
                ) {
                    guard let color = $0 else {
                        return
                    }
                    
                    activityIndicatorView.color = color
                }
                
            case .groupBehavior:
                return .group(title: property.rawValue)
                
            case .isAnimating:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { activityIndicatorView.isAnimating }
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
                    title: property.rawValue,
                    isOn: { activityIndicatorView.hidesWhenStopped }
                ) { hidesWhenStopped in
                    activityIndicatorView.hidesWhenStopped = hidesWhenStopped
                }
                
            }
            
        }
    }
    
}
