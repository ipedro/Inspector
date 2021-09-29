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

    var snapshot: ViewHierarchySnapshot { get }

    var availablePanels: [ElementInspectorPanel] { get }

    var currentPanel: ElementInspectorPanel { get }

    var isCompactVerticalPresentation: Bool { get set }

    var currentPanelIndex: Int { get }
}

final class ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let snapshot: ViewHierarchySnapshot

    let element: ViewHierarchyElement

    let inspectableElements: [InspectorElementLibraryProtocol]

    let availablePanels: [ElementInspectorPanel]

    var selectedPanel: ElementInspectorPanel?

    var currentPanel: ElementInspectorPanel { selectedPanel ?? defaultPanel }

    var isCollapsed: Bool = false

    var isCompactVerticalPresentation: Bool = false

    private var defaultPanel: ElementInspectorPanel {
        if isCompactVerticalPresentation, let firstOtherPanel = availablePanels.filter({ $0 != .preview }).first {
            return firstOtherPanel
        }
        else if let firstPanel = availablePanels.first {
            return firstPanel
        }
        return .preview
    }

    var currentPanelIndex: Int {
        let selectedPanel = selectedPanel ?? defaultPanel

        if let selectedIndex = availablePanels.firstIndex(of: selectedPanel) {
            return selectedIndex
        }

        return UISegmentedControl.noSegment
    }

    init(
        snapshot: ViewHierarchySnapshot,
        element: ViewHierarchyElement,
        selectedPanel: ElementInspectorPanel?,
        inspectableElements: [InspectorElementLibraryProtocol],
        availablePanels: [ElementInspectorPanel]
    ) {
        self.snapshot = snapshot
        self.element = element
        self.inspectableElements = inspectableElements
        self.availablePanels = availablePanels

        if let selectedPanel = selectedPanel {
            self.selectedPanel = availablePanels.contains(selectedPanel) ? selectedPanel : nil
        }
    }
}

// MARK: - ViewHierarchyReferenceDetailViewModelProtocol

extension ElementInspectorViewModel: ViewHierarchyElementDescriptionViewModelProtocol {
    var automaticallyAdjustIndentation: Bool { false }

    var iconImage: UIImage? { snapshot.elementLibraries.icon(for: element.rootView) }

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
