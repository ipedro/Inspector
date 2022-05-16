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
    final class TabBarItemAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Tab Bar Item"

        private weak var tabBarItem: UITabBarItem?

        init?(with object: NSObject) {
            guard
                let viewController = object as? UIViewController,
                let tabBarItem = viewController.tabBarItem
            else {
                return nil
            }

            self.tabBarItem = tabBarItem
        }

        private enum Property: String, Swift.CaseIterable {
            case badgeValue = "Badge"
            case badgeColor = "Badge Color"
            case selectedImage = "Selected Image"
            case titlePositionAdjustment = "Title Position"
            case groupDragAndDrop = "Drag and Drop"
            case isSpringLoaded = "Spring Loaded"
        }

        var properties: [InspectorElementProperty] {
            guard let tabBarItem = tabBarItem else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .badgeValue:
                    return .textField(
                        title: property.rawValue,
                        placeholder: "Value",
                        axis: .vertical,
                        value: { tabBarItem.badgeValue },
                        handler: { tabBarItem.badgeValue = $0 }
                    )
                case .badgeColor:
                    return .colorPicker(
                        title: property.rawValue,
                        emptyTitle: "Default",
                        color: { tabBarItem.badgeColor },
                        handler: { tabBarItem.badgeColor = $0 }
                    )
                case .selectedImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { tabBarItem.selectedImage },
                        handler: { tabBarItem.selectedImage = $0 }
                    )
                case .titlePositionAdjustment:
                    return .uiOffset(
                        title: property.rawValue,
                        offset: { tabBarItem.titlePositionAdjustment },
                        handler: { tabBarItem.titlePositionAdjustment = $0 }
                    )
                case .groupDragAndDrop:
                    return .group(title: property.rawValue)

                case .isSpringLoaded:
                    return .switch(
                        title: property.rawValue,
                        isOn: { tabBarItem.isSpringLoaded },
                        handler: { tabBarItem.isSpringLoaded = $0 }
                    )
                }
            }
        }
    }
}
