//
//  UIScrollViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension AttributesInspectorSection {
    
    final class UIScrollViewSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: CaseIterable {
            case sectionIndicators
            case indicators
            case showsHorizontalScrollIndicator
            case showsVerticalScrollIndicator
            case sectionScrolling
            case isScrollEnabled
            case pagingEnabled
            case isDirectionalLockEnabled
            case sectionBounce
            case bounces
            case bouncesZoom
            case alwaysBounceHorizontal
            case bounceVertically
            case sectionZoom
            case zoomScale
            case minimumZoomScale
            case maximumZoomScale
            case sectionContentTouch
            case delaysContentTouches
            case canCancelContentTouches
            case keyboardDismissMode
        }
        
        private(set) weak var scrollView: UIScrollView?
        
        init?(view: UIView) {
            guard let scrollView = view as? UIScrollView else {
                return nil
            }
            
            self.scrollView = scrollView
        }
        
        let title = "Scroll View"
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap {
            guard let scrollView = scrollView else {
                return nil
            }
            
            switch $0 {
            
            case .sectionIndicators:
                return .subSection(name: "Indicators")
                
            case .indicators:
                return .optionsList(
                    title: "Indicator Style",
                    options: UIScrollView.IndicatorStyle.allCases,
                    selectedIndex: { UIScrollView.IndicatorStyle.allCases.firstIndex(of: scrollView.indicatorStyle) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    scrollView.indicatorStyle = UIScrollView.IndicatorStyle.allCases[newIndex]
                }
                
            case .showsHorizontalScrollIndicator:
                return .toggleButton(
                    title: "Show Horizontal Indicator",
                    isOn: { scrollView.showsHorizontalScrollIndicator }
                ) { showsHorizontalScrollIndicator in
                    scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
                }
                
            case .showsVerticalScrollIndicator:
                return .toggleButton(
                    title: "Show Vertical Indicator",
                    isOn: { scrollView.showsVerticalScrollIndicator }
                ) { showsVerticalScrollIndicator in
                    scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
                }
                
            case .sectionScrolling:
                return .subSection(name: "Scrolling")
                
            case .isScrollEnabled:
                return .toggleButton(
                    title: "Scrolling Enabled",
                    isOn: { scrollView.isScrollEnabled }
                ) { isScrollEnabled in
                    scrollView.isScrollEnabled = isScrollEnabled
                }
                
            case .pagingEnabled:
                return .toggleButton(
                    title: "Paging Enabled",
                    isOn: { scrollView.isPagingEnabled }
                ) { isPagingEnabled in
                    scrollView.isPagingEnabled = isPagingEnabled
                }
                
            case .isDirectionalLockEnabled:
                return .toggleButton(
                    title: "Direction Lock Enabled",
                    isOn: { scrollView.isDirectionalLockEnabled }
                ) { isDirectionalLockEnabled in
                    scrollView.isDirectionalLockEnabled = isDirectionalLockEnabled
                }
                
            case .sectionBounce:
                return .subSection(name: "Bounce")
                
            case .bounces:
                return .toggleButton(
                    title: "Bounce On Scroll",
                    isOn: { scrollView.bounces }
                ) { bounces in
                    scrollView.bounces = bounces
                }
                
            case .bouncesZoom:
                return .toggleButton(
                    title: "Bounce On Zoom",
                    isOn: { scrollView.bouncesZoom }
                ) { bouncesZoom in
                    scrollView.bouncesZoom = bouncesZoom
                }
                
            case .alwaysBounceHorizontal:
                return .toggleButton(
                    title: "Bounce Horizontally",
                    isOn: { scrollView.alwaysBounceHorizontal }
                ) { alwaysBounceHorizontal in
                    scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
                }
                
            case .bounceVertically:
                return .toggleButton(
                    title: "Bounce Vertically",
                    isOn: { scrollView.alwaysBounceVertical }
                ) { alwaysBounceVertical in
                    scrollView.alwaysBounceVertical = alwaysBounceVertical
                }
                
            case .sectionZoom:
                return .separator
                
            case .zoomScale:
                return .cgFloatStepper(
                    title: "Zoom",
                    value: { scrollView.zoomScale },
                    range: { min(scrollView.minimumZoomScale, scrollView.maximumZoomScale)...max(scrollView.minimumZoomScale, scrollView.maximumZoomScale) },
                    stepValue: { 0.1 }
                ) { zoomScale in
                    scrollView.zoomScale = zoomScale
                }
                
            case .minimumZoomScale:
                return .cgFloatStepper(
                    title: "Minimum Scale",
                    value: { scrollView.minimumZoomScale },
                    range: { 0...max(0, scrollView.maximumZoomScale) },
                    stepValue: { 0.1 }
                ) { minimumZoomScale in
                    scrollView.minimumZoomScale = minimumZoomScale
                }
                
            case .maximumZoomScale:
                return .cgFloatStepper(
                    title: "Maximum Scale",
                    value: { scrollView.maximumZoomScale },
                    range: { scrollView.minimumZoomScale...CGFloat.infinity },
                    stepValue: { 0.1 }
                ) { maximumZoomScale in
                    scrollView.maximumZoomScale = maximumZoomScale
                }
                
            case .sectionContentTouch:
                return .subSection(name: "Content Touch")
                
            case .delaysContentTouches:
                return .toggleButton(
                    title: "Delay Touch Down",
                    isOn: { scrollView.delaysContentTouches }
                ) { delaysContentTouches in
                    scrollView.delaysContentTouches = delaysContentTouches
                }
                
            case .canCancelContentTouches:
                return .toggleButton(
                    title: "Can Cancel On Scroll",
                    isOn: { scrollView.canCancelContentTouches }
                ) { canCancelContentTouches in
                    scrollView.canCancelContentTouches = canCancelContentTouches
                }
                
            case .keyboardDismissMode:
                return .optionsList(
                    title: "Keyboard",
                    options: UIScrollView.KeyboardDismissMode.allCases,
                    selectedIndex: { UIScrollView.KeyboardDismissMode.allCases.firstIndex(of: scrollView.keyboardDismissMode) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    scrollView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.allCases[newIndex]
                }
                
            }
            
        }
    }
    
}
