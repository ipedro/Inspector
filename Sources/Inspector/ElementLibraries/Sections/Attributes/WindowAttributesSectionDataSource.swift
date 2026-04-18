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
    final class WindowAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Window"

        private weak var window: UIWindow?

        init?(with object: NSObject) {
            guard let window = object as? UIWindow else { return nil }

            self.window = window
        }

        private enum Property: String, Swift.CaseIterable {
            case canResizeToFitContent = "Can Resize To Fit Content"
            case isKeyWindow = "Is Key"
            case canBecomeKey = "Can Become Key"
            case separator0
            case windowLevel = "Window Level"
            case separator1
            case screenBounds = "Screen Bounds"
            case screenScale = "Screen Scale"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let window else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .canResizeToFitContent:
                    return .init(
                        descriptor: .init(
                            id: "can-resize-to-fit-content",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(window.canResizeToFitContent) },
                        write: { newValue in
                            guard case let .bool(canResizeToFitContent) = newValue else { return }
                            window.canResizeToFitContent = canResizeToFitContent
                        }
                    )
                case .separator0, .separator1:
                    return .init(
                        descriptor: .init(
                            id: property.rawValue,
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )

                case .screenBounds:
                    return .init(
                        descriptor: .init(
                            id: "screen-bounds",
                            title: property.rawValue,
                            kind: .preview,
                            value: .rect,
                            editability: .readOnly
                        ),
                        read: { .rect(window.screen.bounds) },
                        write: nil
                    )
                case .screenScale:
                    return .init(
                        descriptor: .init(
                            id: "screen-scale",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(min: 0, max: Double(window.screen.scale), step: 1, isDecimal: true)),
                            editability: .readOnly
                        ),
                        read: { .number(Double(window.screen.scale)) },
                        write: nil
                    )
                case .windowLevel:
                    return .init(
                        descriptor: .init(
                            id: "window-level",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(step: 1, isDecimal: true)),
                            editability: .readOnly
                        ),
                        read: { .number(Double(window.windowLevel.rawValue)) },
                        write: nil
                    )
                case .isKeyWindow:
                    return .init(
                        descriptor: .init(
                            id: "is-key-window",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .readOnly
                        ),
                        read: { .bool(window.isKeyWindow) },
                        write: nil
                    )
                case .canBecomeKey:
                    return .init(
                        descriptor: .init(
                            id: "can-become-key",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .readOnly
                        ),
                        read: { .bool(window.canBecomeKey) },
                        write: nil
                    )
                }
            }
        }
    }
}
