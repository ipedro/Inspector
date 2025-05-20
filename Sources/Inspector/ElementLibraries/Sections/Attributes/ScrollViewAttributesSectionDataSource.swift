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

extension DefaultElementAttributesLibrary {
    final class ScrollViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Scroll View"

        private weak var scrollView: UIScrollView?

        init?(with object: NSObject) {
            guard let scrollView = object as? UIScrollView else { return nil }

            self.scrollView = scrollView
        }

        private enum Property: String, Swift.CaseIterable {
            case groupIndicators = "Indicators"
            case indicatorStyle = "Indicator Style"
            case showsHorizontalScrollIndicator = "Show Horizontal Indicator"
            case showsVerticalScrollIndicator = "Show Vertical Indicator"
            case groupScrolling = "Scrolling"
            case isScrollEnabled = "Scroll Enabled"
            case pagingEnabled = "Paging Enabled"
            case isDirectionalLockEnabled = "Direction Lock Enabled"
            case groupBounce = "Bounce"
            case bounces = "Bounce On Scroll"
            case bouncesZoom = "Bounce On Zoom"
            case alwaysBounceHorizontal = "Bounce Horizontally"
            case bounceVertically = "Bounce Vertically"
            case groupZoom = "Zoom Separator"
            case zoomScale = "Zoom"
            case minimumZoomScale = "Minimum Scale"
            case maximumZoomScale = "Maximum Scale"
            case groupContentTouch = "Content Touch"
            case delaysContentTouches = "Delay Touch Down"
            case canCancelContentTouches = "Can Cancel On Scroll"
            case keyboardDismissMode = "Keyboard"
        }

        var properties: [InspectorElementProperty] {
            guard let scrollView else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .groupIndicators:
                    .group(title: property.rawValue)
                case .indicatorStyle:
                    .optionsList(
                        title: property.rawValue,
                        options: UIScrollView.IndicatorStyle.allCases.map(\.description),
                        selectedIndex: { UIScrollView.IndicatorStyle.allCases.firstIndex(of: scrollView.indicatorStyle) }
                    ) {
                        guard let newIndex = $0 else { return }

                        let indicatorStyle = UIScrollView.IndicatorStyle.allCases[newIndex]

                        scrollView.indicatorStyle = indicatorStyle
                    }
                case .showsHorizontalScrollIndicator:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.showsHorizontalScrollIndicator }
                    ) { showsHorizontalScrollIndicator in
                        scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
                    }
                case .showsVerticalScrollIndicator:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.showsVerticalScrollIndicator }
                    ) { showsVerticalScrollIndicator in
                        scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
                    }
                case .groupScrolling:
                    .group(title: property.rawValue)
                case .isScrollEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.isScrollEnabled }
                    ) { isScrollEnabled in
                        scrollView.isScrollEnabled = isScrollEnabled
                    }
                case .pagingEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.isPagingEnabled }
                    ) { isPagingEnabled in
                        scrollView.isPagingEnabled = isPagingEnabled
                    }
                case .isDirectionalLockEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.isDirectionalLockEnabled }
                    ) { isDirectionalLockEnabled in
                        scrollView.isDirectionalLockEnabled = isDirectionalLockEnabled
                    }
                case .groupBounce:
                    .group(title: property.rawValue)
                case .bounces:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.bounces }
                    ) { bounces in
                        scrollView.bounces = bounces
                    }
                case .bouncesZoom:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.bouncesZoom }
                    ) { bouncesZoom in
                        scrollView.bouncesZoom = bouncesZoom
                    }
                case .alwaysBounceHorizontal:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.alwaysBounceHorizontal }
                    ) { alwaysBounceHorizontal in
                        scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
                    }
                case .bounceVertically:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.alwaysBounceVertical }
                    ) { alwaysBounceVertical in
                        scrollView.alwaysBounceVertical = alwaysBounceVertical
                    }
                case .groupZoom:
                    .separator
                case .zoomScale:
                    .cgFloatStepper(
                        title: property.rawValue,
                        value: { scrollView.zoomScale },
                        range: { min(scrollView.minimumZoomScale, scrollView.maximumZoomScale)...max(scrollView.minimumZoomScale, scrollView.maximumZoomScale) },
                        stepValue: { 0.1 }
                    ) { zoomScale in
                        scrollView.zoomScale = zoomScale
                    }
                case .minimumZoomScale:
                    .cgFloatStepper(
                        title: property.rawValue,
                        value: { scrollView.minimumZoomScale },
                        range: { 0...max(0, scrollView.maximumZoomScale) },
                        stepValue: { 0.1 }
                    ) { minimumZoomScale in
                        scrollView.minimumZoomScale = minimumZoomScale
                    }
                case .maximumZoomScale:
                    .cgFloatStepper(
                        title: property.rawValue,
                        value: { scrollView.maximumZoomScale },
                        range: { scrollView.minimumZoomScale...CGFloat.infinity },
                        stepValue: { 0.1 }
                    ) { maximumZoomScale in
                        scrollView.maximumZoomScale = maximumZoomScale
                    }
                case .groupContentTouch:
                    .group(title: property.rawValue)
                case .delaysContentTouches:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.delaysContentTouches }
                    ) { delaysContentTouches in
                        scrollView.delaysContentTouches = delaysContentTouches
                    }
                case .canCancelContentTouches:
                    .switch(
                        title: property.rawValue,
                        isOn: { scrollView.canCancelContentTouches }
                    ) { canCancelContentTouches in
                        scrollView.canCancelContentTouches = canCancelContentTouches
                    }
                case .keyboardDismissMode:
                    .optionsList(
                        title: property.rawValue,
                        options: UIScrollView.KeyboardDismissMode.allCases.map(\.description),
                        selectedIndex: { UIScrollView.KeyboardDismissMode.allCases.firstIndex(of: scrollView.keyboardDismissMode) }
                    ) {
                        guard let newIndex = $0 else { return }

                        let keyboardDismissMode = UIScrollView.KeyboardDismissMode.allCases[newIndex]

                        scrollView.keyboardDismissMode = keyboardDismissMode
                    }
                }
            }
        }
    }
}
