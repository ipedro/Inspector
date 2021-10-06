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

extension ElementInspectorAttributesLibrary {
    final class UITabBarAttributesViewModel: InspectorElementViewModelProtocol {
        let title = "Tab Bar"

        private weak var tabBar: UITabBar?

        init?(view: UIView) {
            guard let tabBar = view as? UITabBar else { return nil }
            self.tabBar = tabBar
        }

        private enum Property: String, Swift.CaseIterable {
            case backgroundImage = "Background"
            case shadowImage = "Shadow"
            case selectionIndicatorImage = "Selection"
            case separator
            case style = "Style"
            case translucent = "Translucent"
            case barTintColor = "Bar Tint"
        }

        var properties: [InspectorElementViewModelProperty] {
            guard let tabBar = tabBar else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .style:
                    return .optionsList(
                        title: property.rawValue,
                        options: UIBarStyle.allCases.map { $0.description },
                        selectedIndex: { UIBarStyle.allCases.firstIndex(of: tabBar.barStyle) },
                        handler: { newIndex in
                            guard let index = newIndex else { return }

                            let newStyle = UIBarStyle.allCases[index]
                            tabBar.barStyle = newStyle
                        }
                    )
                case .translucent:
                    return .switch(
                        title: property.rawValue,
                        isOn: { tabBar.isTranslucent },
                        handler: { tabBar.isTranslucent = $0 }
                    )
                case .barTintColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { tabBar.barTintColor },
                        handler: { tabBar.barTintColor = $0 }
                    )
                case .shadowImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { tabBar.shadowImage },
                        handler: { tabBar.shadowImage = $0 }
                    )
                case .backgroundImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { tabBar.backgroundImage },
                        handler: { tabBar.backgroundImage = $0 }
                    )
                case .separator:
                    return .separator

                case .selectionIndicatorImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { tabBar.selectionIndicatorImage },
                        handler: { tabBar.selectionIndicatorImage = $0 }
                    )
                }
            }
        }
    }
}
