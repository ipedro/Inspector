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
    final class NavigationBarAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Navigation Bar"

        private weak var navigationBar: UINavigationBar?

        init?(with object: NSObject) {
            guard let navigationBar = object as? UINavigationBar else { return nil }

            self.navigationBar = navigationBar
        }

        private enum Property: String, Swift.CaseIterable {
            case style = "Style"
            case translucent = "Translucent"
            case prefersLargeTitltes = "Prefers Large Titles"
            case barTintColor = "Bar Tint"
            case shadowImage = "Shadow"
            case backIndicatorImage = "Back"
            case backIndicatorTransitionMaskImage = "Back Mask"
            case separator0
            case groupTitleTextAttributes = "Title Text Attributes"
            case titleFontName = "Title Font Name"
            case titleFontSize = "Title Font Size"
            case titleColor = "Title Color"
            case separator1
            case groupLargeTitleTextAttributes = "Large Title Text Attributes"
            case largeTitleFontName = "Large Title Font Name"
            case largeTitleFontSize = "Large Title Font Size"
            case largeTitleColor = "Large Title Color"
        }

        var properties: [InspectorElementProperty] {
            guard let navigationBar = navigationBar else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .style:
                    return .optionsList(
                        title: property.rawValue,
                        options: UIBarStyle.allCases.map(\.description),
                        selectedIndex: { UIBarStyle.allCases.firstIndex(of: navigationBar.barStyle) },
                        handler: { newIndex in
                            guard let index = newIndex else { return }

                            let newStyle = UIBarStyle.allCases[index]
                            navigationBar.barStyle = newStyle
                        }
                    )
                case .translucent:
                    return .switch(
                        title: property.rawValue,
                        isOn: { [weak self] in self?.navigationBar?.isTranslucent ?? false },
                        handler: { [weak self] isTranslucent in
                            self?.navigationBar?.isTranslucent = isTranslucent
                        }
                    )

                case .prefersLargeTitltes:
                    return .switch(
                        title: property.rawValue,
                        isOn: { [weak self] in self?.navigationBar?.prefersLargeTitles ?? false },
                        handler: { [weak self] prefersLargeTitles in
                            self?.navigationBar?.prefersLargeTitles = prefersLargeTitles
                        }
                    )
                case .barTintColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { [weak self] in self?.navigationBar?.barTintColor },
                        handler: { [weak self] barTintColor in
                            self?.navigationBar?.barTintColor = barTintColor
                        }
                    )
                case .shadowImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { [weak self] in self?.navigationBar?.shadowImage },
                        handler: { [weak self] in
                            guard let navigationBar = self?.navigationBar else { return }
                            navigationBar.shadowImage = $0
                        }
                    )
                case .backIndicatorImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { [weak self] in self?.navigationBar?.backIndicatorImage },
                        handler: { [weak self] in
                            guard let navigationBar = self?.navigationBar else { return }
                            navigationBar.backIndicatorImage = $0
                        }
                    )
                case .backIndicatorTransitionMaskImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { [weak self] in self?.navigationBar?.backIndicatorTransitionMaskImage },
                        handler: { [weak self] in
                            guard let navigationBar = self?.navigationBar else { return }
                            navigationBar.backIndicatorTransitionMaskImage = $0
                        }
                    )
                case .titleFontName:
                    return .fontNamePicker(
                        title: property.rawValue,
                        fontProvider: { [weak self] in self?.navigationBar?.titleTextAttributes?[.font] as? UIFont },
                        handler: { [weak self] newValue in
                            self?.navigationBar?.titleTextAttributes?[.font] = newValue
                        }
                    )
                case .titleFontSize:
                    return .fontSizeStepper(
                        title: property.rawValue,
                        fontProvider: { [weak self] in self?.navigationBar?.titleTextAttributes?[.font] as? UIFont },
                        handler: { [weak self] font in
                            self?.navigationBar?.titleTextAttributes?[.font] = font
                        }
                    )
                case .titleColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { [weak self] in self?.navigationBar?.titleTextAttributes?[.foregroundColor] as? UIColor },
                        handler: { [weak self] foregroundColor in
                            self?.navigationBar?.titleTextAttributes?[.foregroundColor] = foregroundColor
                        }
                    )
                case .separator0,
                     .separator1:
                    return .separator

                case .groupTitleTextAttributes,
                     .groupLargeTitleTextAttributes:
                    return .group(title: property.rawValue)

                case .largeTitleFontName:
                    return .fontNamePicker(
                        title: property.rawValue,
                        fontProvider: { [weak self] in self?.navigationBar?.largeTitleTextAttributes?[.font] as? UIFont },
                        handler: { [weak self] newValue in
                            self?.navigationBar?.largeTitleTextAttributes?[.font] = newValue
                        }
                    )
                case .largeTitleFontSize:
                    return .fontSizeStepper(
                        title: property.rawValue,
                        fontProvider: { [weak self] in self?.navigationBar?.largeTitleTextAttributes?[.font] as? UIFont },
                        handler: { [weak self] font in
                            self?.navigationBar?.largeTitleTextAttributes?[.font] = font
                        }
                    )
                case .largeTitleColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { [weak self] in self?.navigationBar?.largeTitleTextAttributes?[.foregroundColor] as? UIColor },
                        handler: { [weak self] foregroundColor in
                            self?.navigationBar?.largeTitleTextAttributes?[.foregroundColor] = foregroundColor
                        }
                    )
                }
            }
        }
    }
}
