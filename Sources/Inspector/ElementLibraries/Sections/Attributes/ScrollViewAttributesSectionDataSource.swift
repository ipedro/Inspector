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

import InspectorContract
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

        var propertyBindings: [InspectorPropertyBinding] {
            guard let scrollView else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .groupIndicators:
                    .init(
                        descriptor: .init(
                            id: "group-indicators",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .indicatorStyle:
                    .init(
                        descriptor: .init(
                            id: "indicator-style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIScrollView.IndicatorStyle.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIScrollView.IndicatorStyle.allCases.firstIndex(of: scrollView.indicatorStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            scrollView.indicatorStyle = UIScrollView.IndicatorStyle.allCases[newIndex]
                        }
                    )
                case .showsHorizontalScrollIndicator:
                    .init(
                        descriptor: .init(
                            id: "shows-horizontal-scroll-indicator",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.showsHorizontalScrollIndicator) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.showsHorizontalScrollIndicator = isOn
                        }
                    )
                case .showsVerticalScrollIndicator:
                    .init(
                        descriptor: .init(
                            id: "shows-vertical-scroll-indicator",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.showsVerticalScrollIndicator) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.showsVerticalScrollIndicator = isOn
                        }
                    )
                case .groupScrolling:
                    .init(
                        descriptor: .init(
                            id: "group-scrolling",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .isScrollEnabled:
                    .init(
                        descriptor: .init(
                            id: "is-scroll-enabled",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.isScrollEnabled) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.isScrollEnabled = isOn
                        }
                    )
                case .pagingEnabled:
                    .init(
                        descriptor: .init(
                            id: "paging-enabled",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.isPagingEnabled) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.isPagingEnabled = isOn
                        }
                    )
                case .isDirectionalLockEnabled:
                    .init(
                        descriptor: .init(
                            id: "is-directional-lock-enabled",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.isDirectionalLockEnabled) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.isDirectionalLockEnabled = isOn
                        }
                    )
                case .groupBounce:
                    .init(
                        descriptor: .init(
                            id: "group-bounce",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .bounces:
                    .init(
                        descriptor: .init(
                            id: "bounces",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.bounces) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.bounces = isOn
                        }
                    )
                case .bouncesZoom:
                    .init(
                        descriptor: .init(
                            id: "bounces-zoom",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.bouncesZoom) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.bouncesZoom = isOn
                        }
                    )
                case .alwaysBounceHorizontal:
                    .init(
                        descriptor: .init(
                            id: "always-bounce-horizontal",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.alwaysBounceHorizontal) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.alwaysBounceHorizontal = isOn
                        }
                    )
                case .bounceVertically:
                    .init(
                        descriptor: .init(
                            id: "always-bounce-vertical",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.alwaysBounceVertical) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.alwaysBounceVertical = isOn
                        }
                    )
                case .groupZoom:
                    .init(
                        descriptor: .init(
                            id: "group-zoom",
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .zoomScale:
                    .init(
                        descriptor: .init(
                            id: "zoom-scale",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(
                                min: Double(min(scrollView.minimumZoomScale, scrollView.maximumZoomScale)),
                                max: Double(max(scrollView.minimumZoomScale, scrollView.maximumZoomScale)),
                                step: 0.1,
                                isDecimal: true
                            )),
                            editability: .editable
                        ),
                        read: { .number(Double(scrollView.zoomScale)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            scrollView.zoomScale = CGFloat(value)
                        }
                    )
                case .minimumZoomScale:
                    .init(
                        descriptor: .init(
                            id: "minimum-zoom-scale",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(
                                min: 0,
                                max: Double(max(0, scrollView.maximumZoomScale)),
                                step: 0.1,
                                isDecimal: true
                            )),
                            editability: .editable
                        ),
                        read: { .number(Double(scrollView.minimumZoomScale)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            scrollView.minimumZoomScale = CGFloat(value)
                        }
                    )
                case .maximumZoomScale:
                    .init(
                        descriptor: .init(
                            id: "maximum-zoom-scale",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(
                                min: Double(scrollView.minimumZoomScale),
                                step: 0.1,
                                isDecimal: true
                            )),
                            editability: .editable
                        ),
                        read: { .number(Double(scrollView.maximumZoomScale)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            scrollView.maximumZoomScale = CGFloat(value)
                        }
                    )
                case .groupContentTouch:
                    .init(
                        descriptor: .init(
                            id: "group-content-touch",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .delaysContentTouches:
                    .init(
                        descriptor: .init(
                            id: "delays-content-touches",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.delaysContentTouches) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.delaysContentTouches = isOn
                        }
                    )
                case .canCancelContentTouches:
                    .init(
                        descriptor: .init(
                            id: "can-cancel-content-touches",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(scrollView.canCancelContentTouches) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            scrollView.canCancelContentTouches = isOn
                        }
                    )
                case .keyboardDismissMode:
                    .init(
                        descriptor: .init(
                            id: "keyboard-dismiss-mode",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIScrollView.KeyboardDismissMode.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIScrollView.KeyboardDismissMode.allCases.firstIndex(of: scrollView.keyboardDismissMode)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            scrollView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.allCases[newIndex]
                        }
                    )
                }
            }
        }
    }
}
