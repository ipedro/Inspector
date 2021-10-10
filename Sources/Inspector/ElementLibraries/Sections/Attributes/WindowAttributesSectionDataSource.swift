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

extension ElementAttributesLibrary {
    final class WindowAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Window"

        private weak var window: UIWindow?

        init?(view: UIView) {
            guard let window = view as? UIWindow else { return nil }

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

        var properties: [InspectorElementProperty] {
            guard let window = window else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .canResizeToFitContent:
                    return .switch(
                        title: property.rawValue,
                        isOn: { window.canResizeToFitContent },
                        handler: { canResizeToFitContent in
                            window.canResizeToFitContent = canResizeToFitContent
                        }
                    )
                case .separator0, .separator1:
                    return .separator

                case .screenBounds:
                    return .cgRect(
                        title: property.rawValue,
                        rect: { window.screen.bounds },
                        handler: nil
                    )
                case .screenScale:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { window.screen.scale },
                        range: { 0...window.screen.scale },
                        stepValue: { 1 },
                        handler: nil
                    )
                case .windowLevel:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { window.windowLevel.rawValue },
                        range: { -Double.infinity...Double.infinity },
                        stepValue: { 1 },
                        handler: nil
                    )
                case .isKeyWindow:
                    return .switch(
                        title: property.rawValue,
                        isOn: { window.isKeyWindow },
                        handler: nil
                    )
                case .canBecomeKey:
                    #if swift(>=5.5)
                    guard #available(iOS 15.0, *) else { return nil }

                    return .switch(
                        title: property.rawValue,
                        isOn: { window.canBecomeKey },
                        handler: nil
                    )
                    #else
                    return nil
                    #endif
                }
            }
        }
    }
}
