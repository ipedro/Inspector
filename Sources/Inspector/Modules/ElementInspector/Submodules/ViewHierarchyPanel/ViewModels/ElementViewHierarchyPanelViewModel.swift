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

protocol ElementInspectorPanelViewModelProtocol: ViewHierarchyReferenceDetailViewModelProtocol & AnyObject {
    var parent: ElementInspectorPanelViewModelProtocol? { get set }
    var reference: ViewHierarchyReference { get }
    var availablePanels: [ElementInspectorPanel] { get }
    var isCollapsed: Bool { get set }
}

extension ElementInspectorPanelViewModelProtocol {
    var availablePanels: [ElementInspectorPanel] { ElementInspectorPanel.cases(for: reference) }
}

final class ElementViewHierarchyPanelViewModel {
    weak var parent: ElementInspectorPanelViewModelProtocol?

    private var _isCollapsed: Bool

    var title: String { reference.elementName }

    var subtitle: String { reference.elementDescription }

    let rootDepth: Int

    var thumbnailImage: UIImage?

    // MARK: - Properties

    let reference: ViewHierarchyReference

    init(
        reference: ViewHierarchyReference,
        parent: ElementInspectorPanelViewModelProtocol? = nil,
        rootDepth: Int,
        thumbnailImage: UIImage?,
        isCollapsed: Bool
    ) {
        self.parent = parent
        self.reference = reference
        self.rootDepth = rootDepth
        self.thumbnailImage = thumbnailImage
        self._isCollapsed = isCollapsed
    }
}

// MARK: - ElementViewHierarchyPanelViewModelProtocol

extension ElementViewHierarchyPanelViewModel: ElementInspectorPanelViewModelProtocol {
    var automaticallyAdjustIndentation: Bool { true }

    var titleFont: UIFont {
        ElementInspector.appearance.titleFont(forRelativeDepth: relativeDepth + 2)
    }

    var isHidden: Bool { parent?.isCollapsed == true || parent?.isHidden == true }

    var showCollapseButton: Bool { isContainer }

    var isContainer: Bool { reference.isContainer }

    var relativeDepth: Int { reference.depth - rootDepth }

    var isCollapsed: Bool {
        get {
            isContainer ? _isCollapsed : true
        }
        set {
            guard isContainer else {
                return
            }

            _isCollapsed = newValue
        }
    }
}

// MARK: - Hashable

extension ElementViewHierarchyPanelViewModel: Hashable {
    static func == (lhs: ElementViewHierarchyPanelViewModel, rhs: ElementViewHierarchyPanelViewModel) -> Bool {
        lhs.reference.viewIdentifier == rhs.reference.viewIdentifier
    }

    func hash(into hasher: inout Hasher) {
        reference.viewIdentifier.hash(into: &hasher)
    }
}

// MARK: - Images

private extension ElementViewHierarchyPanelViewModel {
    static let thumbnailImageLostConnection = IconKit.imageOfWifiExlusionMark(
        CGSize(
            width: ElementInspector.appearance.horizontalMargins * 1.5,
            height: ElementInspector.appearance.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)

    static let thumbnailImageIsHidden = IconKit.imageOfEyeSlashFill(
        CGSize(
            width: ElementInspector.appearance.horizontalMargins * 1.5,
            height: ElementInspector.appearance.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)
}
