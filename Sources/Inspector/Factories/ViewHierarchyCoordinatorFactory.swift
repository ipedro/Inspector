//  Copyright (c) 2022 Pedro Almeida
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

protocol ViewHierarchyCoordinatorFactoryProtocol {
    static func makeCoordinator(with windows: [UIWindow],
                                operationQueue: OperationQueue,
                                customization: InspectorCustomizationProviding?,
                                defaultLayers: [Inspector.ViewHierarchyLayer]) -> ViewHierarchyCoordinator
}

enum ViewHierarchyCoordinatorFactory: ViewHierarchyCoordinatorFactoryProtocol {
    static func makeCoordinator(with windows: [UIWindow],
                                operationQueue: OperationQueue,
                                customization: InspectorCustomizationProviding?,
                                defaultLayers: [Inspector.ViewHierarchyLayer]) -> ViewHierarchyCoordinator
    {
        var layers: [Inspector.ViewHierarchyLayer] {
            var layers = defaultLayers

            if let customLayers = customization?.viewHierarchyLayers {
                layers.append(contentsOf: customLayers)
            }

            return layers.uniqueValues()
        }

        var colorScheme: ViewHierarchyColorScheme {
            guard let colorScheme = customization?.elementColorProvider else {
                return .default
            }

            return ViewHierarchyColorScheme { view in
                guard let color = colorScheme.value(for: view) else {
                    return ViewHierarchyColorScheme.default.value(for: view)
                }

                return color
            }
        }

        var catalog: ViewHierarchyElementCatalog {
            .init(
                libraries: libraries,
                iconProvider: .init() { object in
                    if
                        let elementIconProvider = customization?.elementIconProvider,
                        let view = object as? UIView,
                        let customIcon = elementIconProvider.value(for: view)
                    {
                        return customIcon
                    }
                    return ViewHierarchyElementIconProvider.default.value(for: object)
                }
            )
        }

        var libraries: [ElementInspectorPanel: [InspectorElementLibraryProtocol]] {
            var dictionary: [ElementInspectorPanel: [InspectorElementLibraryProtocol]] = [:]

            customization?.elementLibraries?.keys.forEach { customPanel in
                dictionary[customPanel.rawValue] = customization?.elementLibraries?[customPanel]
            }

            ElementInspectorPanel.allCases.forEach { panel in
                var libraries = dictionary[panel] ?? []
                libraries.append(contentsOf: panel.defaultLibraries)
                dictionary[panel] = libraries
            }

            return dictionary
        }

        let coordinator = ViewHierarchyCoordinator(
            .init(
                catalog: catalog,
                colorScheme: colorScheme,
                layers: layers
            ),
            presentedBy: operationQueue
        )

        return coordinator
    }
}

private extension ElementInspectorPanel {
    var defaultLibraries: [InspectorElementLibraryProtocol] {
        switch self {
        case .identity: return DefaultElementIdentityLibrary.allCases
        case .attributes: return DefaultElementAttributesLibrary.allCases
        case .size: return DefaultElementSizeLibrary.allCases
        case .children: return []
        }
    }
}
