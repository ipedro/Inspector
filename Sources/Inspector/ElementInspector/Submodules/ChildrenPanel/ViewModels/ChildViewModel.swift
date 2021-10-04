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

protocol ElementChildrenPanelItemViewModelProtocol: ViewHierarchyElementDescriptionViewModelProtocol & AnyObject {
    var parent: ElementChildrenPanelItemViewModelProtocol? { get set }
    var element: ViewHierarchyElement { get }
    var isCollapsed: Bool { get set }
    var availablePanels: [ElementInspectorPanel] { get }
}

extension ElementChildrenPanelViewModel {
    final class ChildViewModel {
        weak var parent: ElementChildrenPanelItemViewModelProtocol?

        private var _isCollapsed: Bool {
            didSet {
                if !_isCollapsed, relativeDepth > .zero {
                    animatedDisplay = true
                }
            }
        }

        let rootDepth: Int

        var iconImage: UIImage?

        // MARK: - Properties

        let element: ViewHierarchyElement

        lazy var animatedDisplay: Bool = relativeDepth > .zero

        init(
            element: ViewHierarchyElement,
            parent: ElementChildrenPanelItemViewModelProtocol? = nil,
            rootDepth: Int,
            thumbnailImage: UIImage?,
            isCollapsed: Bool
        ) {
            self.parent = parent
            self.element = element
            self.rootDepth = rootDepth
            self.iconImage = thumbnailImage
            _isCollapsed = isCollapsed
        }
    }
}

// MARK: - ElementChildrenPanelTableViewCellViewModelProtocol

extension ElementChildrenPanelViewModel.ChildViewModel: ElementChildrenPanelTableViewCellViewModelProtocol {
    var availablePanels: [ElementInspectorPanel] {
        ElementInspectorPanel.allCases(for: element)
    }

    var appearance: (transform: CGAffineTransform, alpha: CGFloat) {
        if animatedDisplay {
            return (transform: ElementInspector.appearance.panelInitialTransform, alpha: .zero)
        }
        return (transform: .identity, alpha: 1)
    }

    var showDisclosureIcon: Bool { relativeDepth > .zero }

    var automaticallyAdjustIndentation: Bool { relativeDepth > .zero }

    var title: String? { relativeDepth > .zero ? element.elementName : nil }

    var subtitle: String? { relativeDepth > .zero ? element.shortElementDescription : element.elementDescription }

    var titleFont: UIFont { ElementInspector.appearance.titleFont(forRelativeDepth: relativeDepth) }

    var subtitleFont: UIFont { ElementInspector.appearance.font(forRelativeDepth: relativeDepth) }

    var isHidden: Bool {
        guard let parent = parent as? ElementChildrenPanelTableViewCellViewModelProtocol else {
            return parent?.isCollapsed == true
        }

        return parent.isCollapsed == true || parent.isHidden == true
    }

    var isCollapseButtonEnabled: Bool {
        relativeDepth < ElementInspector.configuration.childrenListMaximumInteractiveDepth
    }

    var hideCollapseButton: Bool {
        if relativeDepth == .zero { return true }

        return !isContainer
    }

    var isContainer: Bool { element.isContainer }

    var relativeDepth: Int { element.depth - rootDepth }

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

extension ElementChildrenPanelViewModel.ChildViewModel: Hashable {
    static func == (lhs: ElementChildrenPanelViewModel.ChildViewModel, rhs: ElementChildrenPanelViewModel.ChildViewModel) -> Bool {
        lhs.element == rhs.element
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(element)
    }
}

// MARK: - Images

private extension ElementChildrenPanelViewModel.ChildViewModel {
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