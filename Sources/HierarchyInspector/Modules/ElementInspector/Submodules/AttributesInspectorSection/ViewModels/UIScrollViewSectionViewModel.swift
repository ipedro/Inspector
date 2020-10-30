//
//  UIScrollViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension AttributesInspectorSection {
    
    final class UIScrollViewSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: String, CaseIterable {
            case groupIndicators                = "Indicators"
            case indicatorStyle                 = "Indicator Style"
            case showsHorizontalScrollIndicator = "shows Horizontal Scroll Indicator"
            case showsVerticalScrollIndicator   = "shows Vertical Scroll Indicator"
            case groupScrolling                 = "Scrolling"
            case isScrollEnabled                = "Scroll Enabled"
            case pagingEnabled                  = "pagingEnabled"
            case isDirectionalLockEnabled       = "DirectionalLockEnabled"
            case groupBounce                    = "groupBounce"
            case bounces                        = "bounces"
            case bouncesZoom                    = "bouncesZoom"
            case alwaysBounceHorizontal         = "alwaysBounceHorizontal"
            case bounceVertically               = "bounceVertically"
            case groupZoom                      = "groupZoom"
            case zoomScale                      = "zoomScale"
            case minimumZoomScale               = "minimumZoomScale"
            case maximumZoomScale               = "maximumZoomScale"
            case groupContentTouch              = "groupContentTouch"
            case delaysContentTouches           = "delaysContentTouches"
            case canCancelContentTouches        = "canCancelContentTouches"
            case keyboardDismissMode            = "keyboardDismissMode"
        }
        
        let title = "Scroll View"
        
        private(set) weak var scrollView: UIScrollView?
        
        init?(view: UIView) {
            guard let scrollView = view as? UIScrollView else {
                return nil
            }
            
            self.scrollView = scrollView
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let scrollView = scrollView else {
                return nil
            }
            
            switch property {
            
            case .groupIndicators:
                return .group(title: property.rawValue)
                
            case .indicatorStyle:
                return .optionsList(
                    title: property.rawValue,
                    options: UIScrollView.IndicatorStyle.allCases,
                    selectedIndex: { UIScrollView.IndicatorStyle.allCases.firstIndex(of: scrollView.indicatorStyle) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let indicatorStyle = UIScrollView.IndicatorStyle.allCases[newIndex]
                    
                    scrollView.indicatorStyle = indicatorStyle
                }
                
            case .showsHorizontalScrollIndicator:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.showsHorizontalScrollIndicator }
                ) { showsHorizontalScrollIndicator in
                    scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
                }
                
            case .showsVerticalScrollIndicator:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.showsVerticalScrollIndicator }
                ) { showsVerticalScrollIndicator in
                    scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
                }
                
            case .groupScrolling:
                return .group(title: property.rawValue)
                
            case .isScrollEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.isScrollEnabled }
                ) { isScrollEnabled in
                    scrollView.isScrollEnabled = isScrollEnabled
                }
                
            case .pagingEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.isPagingEnabled }
                ) { isPagingEnabled in
                    scrollView.isPagingEnabled = isPagingEnabled
                }
                
            case .isDirectionalLockEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.isDirectionalLockEnabled }
                ) { isDirectionalLockEnabled in
                    scrollView.isDirectionalLockEnabled = isDirectionalLockEnabled
                }
                
            case .groupBounce:
                return .group(title: property.rawValue)
                
            case .bounces:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.bounces }
                ) { bounces in
                    scrollView.bounces = bounces
                }
                
            case .bouncesZoom:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.bouncesZoom }
                ) { bouncesZoom in
                    scrollView.bouncesZoom = bouncesZoom
                }
                
            case .alwaysBounceHorizontal:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.alwaysBounceHorizontal }
                ) { alwaysBounceHorizontal in
                    scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
                }
                
            case .bounceVertically:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.alwaysBounceVertical }
                ) { alwaysBounceVertical in
                    scrollView.alwaysBounceVertical = alwaysBounceVertical
                }
                
            case .groupZoom:
                return .separator(title: property.rawValue)
                
            case .zoomScale:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { scrollView.zoomScale },
                    range: { min(scrollView.minimumZoomScale, scrollView.maximumZoomScale)...max(scrollView.minimumZoomScale, scrollView.maximumZoomScale) },
                    stepValue: { 0.1 }
                ) { zoomScale in
                    scrollView.zoomScale = zoomScale
                }
                
            case .minimumZoomScale:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { scrollView.minimumZoomScale },
                    range: { 0...max(0, scrollView.maximumZoomScale) },
                    stepValue: { 0.1 }
                ) { minimumZoomScale in
                    scrollView.minimumZoomScale = minimumZoomScale
                }
                
            case .maximumZoomScale:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { scrollView.maximumZoomScale },
                    range: { scrollView.minimumZoomScale...CGFloat.infinity },
                    stepValue: { 0.1 }
                ) { maximumZoomScale in
                    scrollView.maximumZoomScale = maximumZoomScale
                }
                
            case .groupContentTouch:
                return .group(title: property.rawValue)
                
            case .delaysContentTouches:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.delaysContentTouches }
                ) { delaysContentTouches in
                    scrollView.delaysContentTouches = delaysContentTouches
                }
                
            case .canCancelContentTouches:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { scrollView.canCancelContentTouches }
                ) { canCancelContentTouches in
                    scrollView.canCancelContentTouches = canCancelContentTouches
                }
                
            case .keyboardDismissMode:
                return .optionsList(
                    title: property.rawValue,
                    options: UIScrollView.KeyboardDismissMode.allCases,
                    selectedIndex: { UIScrollView.KeyboardDismissMode.allCases.firstIndex(of: scrollView.keyboardDismissMode) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let keyboardDismissMode = UIScrollView.KeyboardDismissMode.allCases[newIndex]
                    
                    scrollView.keyboardDismissMode = keyboardDismissMode
                }
                
            }
            
        }
    }
    
}
