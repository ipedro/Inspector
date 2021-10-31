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

struct ViewHierarchySnapshot: ExpirableProtocol {
    let expirationDate = Date().addingTimeInterval(Inspector.configuration.snapshotExpirationTimeInterval)

    let availableLayers: [ViewHierarchyLayer]

    let populatedLayers: [ViewHierarchyLayer]

    let viewHierarchy: [ViewHierarchyElementReference]

    init(layers: [ViewHierarchyLayer], window: ViewHierarchyElement, rootViewController: ViewHierarchyController) {
        availableLayers = layers.uniqueValues()

        let allViewControllers = [rootViewController] + rootViewController.allChildren

        var dict = [ViewHierarchyElementKey: ViewHierarchyController]()

        for child in allViewControllers {
            if let viewController = child as? ViewHierarchyController {
                let key = ViewHierarchyElementKey(reference: viewController.rootElement)
                dict[key] = viewController
            }
        }

        var viewHierarchy = [ViewHierarchyElementReference]()

        window.inspectableChildren.reversed().enumerated().forEach { index, element in
            let key = ViewHierarchyElementKey(reference: element)

            viewHierarchy.insert(element, at: .zero)

            guard
                let viewController = dict[key],
                let element = element as? ViewHierarchyElement
            else {
                return
            }

            let depth = element.depth
            let parent = element.parent

            element.parent = viewController

            viewController.parent = parent
            viewController.rootElement = element
            viewController.children = [element]

            // must set depth as last step
            viewController.depth = depth

            if let index = parent?.children.firstIndex(where: { $0 === element }) {
                parent?.children[index] = viewController
            }

            viewHierarchy.insert(viewController, at: .zero)
        }

        self.viewHierarchy = viewHierarchy

        populatedLayers = availableLayers.filter {
            $0.filter(flattenedViewHierarchy: window.inspectableChildren).isEmpty == false
        }
    }
}
