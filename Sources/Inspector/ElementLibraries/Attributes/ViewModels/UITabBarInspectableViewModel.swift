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
    final class UITabBarInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case backgroundImage = "Background"
            case shadowImage = "Shadow"
            case selectionIndicatorImage = "Selection"
            case separator
            case style = "Style"
            case translucent = "Translucent"
            case barTintColor = "Bar Tint"
        }

        let title = "Tab Bar"

        private(set) weak var tabBar: UITabBar?

        init?(view: UIView) {
            guard let tabBar = view as? UITabBar else { return nil }
            self.tabBar = tabBar
        }

        var properties: [InspectorElementViewModelProperty] {
            Property.allCases.compactMap { property in
                switch property {
                case .style:
                    return .optionsList(
                        title: property.rawValue,
                        options: UIBarStyle.allCases.map { $0.description },
                        selectedIndex: { [weak self] in
                            guard
                                let tabBar = self?.tabBar,
                                let index = UIBarStyle.allCases.firstIndex(of: tabBar.barStyle)
                            else {
                                return nil
                            }
                            return index
                        },
                        handler: { [weak self] newIndex in
                            guard
                                let tabBar = self?.tabBar,
                                let index = newIndex
                            else {
                                return
                            }

                            let newStyle = UIBarStyle.allCases[index]
                            tabBar.barStyle = newStyle
                        }
                    )

                case .translucent:
                    return .switch(
                        title: property.rawValue,
                        isOn: { [weak self] in self?.tabBar?.isTranslucent ?? false },
                        handler: { [weak self] isTranslucent in
                            self?.tabBar?.isTranslucent = isTranslucent
                        }
                    )

                case .barTintColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { [weak self] in self?.tabBar?.barTintColor },
                        handler: { [weak self] barTintColor in
                            self?.tabBar?.barTintColor = barTintColor
                        }
                    )

                case .shadowImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { [weak self] in self?.tabBar?.shadowImage },
                        handler: { [weak self] in
                            guard let tabBar = self?.tabBar else { return }
                            tabBar.shadowImage = $0
                        }
                    )

                case .backgroundImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { [weak self] in self?.tabBar?.backgroundImage },
                        handler: { [weak self] in
                            guard let tabBar = self?.tabBar else { return }
                            tabBar.backgroundImage = $0
                        }
                    )
                case .separator:
                    return .separator

                case .selectionIndicatorImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { [weak self] in self?.tabBar?.selectionIndicatorImage },
                        handler: { [weak self] in
                            guard let tabBar = self?.tabBar else { return }
                            tabBar.selectionIndicatorImage = $0
                        }
                    )
                }
            }
        }
    }
}
