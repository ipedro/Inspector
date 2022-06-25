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

protocol ElementInspectorViewModelProtocol: AnyObject {
    var isFullHeightPresentation: Bool { get set }

    var element: ViewHierarchyElementReference { get }

    var catalog: ViewHierarchyElementCatalog { get }

    var availablePanels: [ElementInspectorPanel] { get }

    var currentPanel: ElementInspectorPanel { get }

    var currentPanelIndex: Int { get }

    var title: String { get }
}

final class ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let element: ViewHierarchyElementReference

    let catalog: ViewHierarchyElementCatalog

    let availablePanels: [ElementInspectorPanel]

    var currentPanel: ElementInspectorPanel

    var isCollapsed: Bool = false

    var isFullHeightPresentation: Bool = true

    private static var defaultPanel: ElementInspectorPanel { Inspector.sharedInstance.configuration.elementInspectorConfiguration.defaultPanel }

    var title: String { element.displayName }

    var currentPanelIndex: Int {
        guard let index = availablePanels.firstIndex(of: currentPanel) else {
            return UISegmentedControl.noSegment
        }
        return index
    }

    init(
        catalog: ViewHierarchyElementCatalog,
        element: ViewHierarchyElementReference,
        preferredPanel: ElementInspectorPanel?,
        availablePanels: [ElementInspectorPanel]
    ) {
        self.catalog = catalog
        self.element = element
        self.availablePanels = availablePanels

        currentPanel = {
            guard
                let preferredPanel = preferredPanel,
                availablePanels.contains(preferredPanel)
            else {
                return availablePanels.first ?? Self.defaultPanel
            }
            return preferredPanel
        }()
    }

    var summaryInfo: ViewHierarchyElementSummary {
        ViewHierarchyElementSummary(
            iconImage: element.iconImage,
            isContainer: false,
            subtitle: element.elementDescription,
            title: element.displayName
        )
    }
}
