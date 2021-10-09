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

extension Manager: ViewHierarchyCoordinatorDataSource {
    var rootViewController: UIViewController? { host?.window?.rootViewController }

    var rootView: UIView? { host?.window }

    var layers: [Inspector.ViewHierarchyLayer] {
        var layers: [Inspector.ViewHierarchyLayer] = [
            .allViews,
            .viewControllers,
            .internalViews,
        ]

        if let hostLayers = host?.inspectorViewHierarchyLayers {
            layers.append(contentsOf: hostLayers)
        }

        return layers.uniqueValues()
    }

    var colorScheme: ViewHierarchyColorScheme {
        guard let colorScheme = host?.inspectorViewHierarchyColorScheme else {
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
        .init(libraries: libraries, iconProvider: iconProvider)
    }

    var libraries: [ElementInspectorPanel: [InspectorElementLibraryProtocol]] {
        var dictionary: [ElementInspectorPanel: [InspectorElementLibraryProtocol]] = [:]

        host?.inspectorElementLibraries?.keys.forEach { hostPanel in
            if let libraries = host?.inspectorElementLibraries?[hostPanel] {
                dictionary[hostPanel.rawValue] = libraries
            }
        }

        ElementInspectorPanel.allCases.forEach { panel in
            var libraries = dictionary[panel] ?? []

            switch panel {
            case .identity:
                libraries.append(contentsOf: ElementInspectorIdentityLibrary.allCases)

            case .attributes:
                libraries.append(contentsOf: ElementInspectorAttributesLibrary.allCases)

            case .size:
                libraries.append(contentsOf: ElementInspectorSizeLibrary.allCases)

            case .children:
                break
            }

            dictionary[panel] = libraries
        }

        return dictionary
    }

    var iconProvider: ViewHierarchyElementIconProvider {
        let hostProvider = host?.inspectorElementIconProvider

        return .init { view in
            guard
                let view = view,
                view.isHidden == false,
                let hostIcon = hostProvider?.value(for: view)
            else {
                return ViewHierarchyElementIconProvider.default.value(for: view) ?? .emptyViewSymbol
            }
            return hostIcon
        }
    }
}
