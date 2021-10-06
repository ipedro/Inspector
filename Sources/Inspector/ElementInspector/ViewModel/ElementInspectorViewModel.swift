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

protocol ElementInspectorViewModelProtocol: AnyObject & ViewHierarchyElementDescriptionViewModelProtocol {
    var element: ViewHierarchyElement { get }

    var catalog: ViewHierarchyElementCatalog { get }

    var availablePanels: [ElementInspectorPanel] { get }

    var currentPanel: ElementInspectorPanel { get }

    var isFullHeightPresentation: Bool { get set }

    var currentPanelIndex: Int { get }

    var defaultPanel: ElementInspectorPanel { get set }
}

final class ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let element: ViewHierarchyElement

    let catalog: ViewHierarchyElementCatalog

    let availablePanels: [ElementInspectorPanel]

    var selectedPanel: ElementInspectorPanel?

    var currentPanel: ElementInspectorPanel { selectedPanel ?? defaultPanel }

    var isCollapsed: Bool = false

    var isFullHeightPresentation: Bool = true

    static var defaultPanel: ElementInspectorPanel {
        get { ElementInspector.configuration.defaultPanel }
        set { ElementInspector.configuration.defaultPanel = newValue }
    }

    var defaultPanel: ElementInspectorPanel {
        get { Self.defaultPanel }
        set { Self.defaultPanel = newValue }
    }

    var currentPanelIndex: Int {
        guard
            let panel = selectedPanel,
            let index = availablePanels.firstIndex(of: panel)
        else {
            return UISegmentedControl.noSegment
        }
        return index
    }

    init(
        catalog: ViewHierarchyElementCatalog,
        element: ViewHierarchyElement,
        selectedPanel: ElementInspectorPanel?,
        availablePanels: [ElementInspectorPanel]
    ) {
        self.catalog = catalog
        self.element = element
        self.availablePanels = availablePanels

        self.selectedPanel = {
            let preferredPanel = selectedPanel ?? Self.defaultPanel

            guard availablePanels.contains(preferredPanel) else { return availablePanels.first }

            return preferredPanel
        }()

        if let selectedPanel = selectedPanel {
            self.selectedPanel = availablePanels.contains(selectedPanel) ? selectedPanel : nil
        }
    }
}

// MARK: - ViewHierarchyReferenceDetailViewModelProtocol

extension ElementInspectorViewModel: ViewHierarchyElementDescriptionViewModelProtocol {
    var automaticallyAdjustIndentation: Bool { false }

    var iconImage: UIImage? { element.iconImage }

    var title: String? { element.elementName }

    var titleFont: UIFont { ElementInspector.appearance.titleFont(forRelativeDepth: .zero) }

    var subtitle: String? { element.elementDescription }

    var subtitleFont: UIFont { ElementInspector.appearance.font(forRelativeDepth: .zero) }

    var isContainer: Bool { false }

    var isCollapseButtonEnabled: Bool { false }

    var hideCollapseButton: Bool { true }

    var isHidden: Bool { false }

    var relativeDepth: Int { .zero }
}
