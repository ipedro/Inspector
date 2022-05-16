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

protocol ElementChildrenPanelItemViewModelProtocol: AnyObject {
    var parent: ElementChildrenPanelItemViewModelProtocol? { get set }
    var element: ViewHierarchyElementReference { get }
    var isCollapsed: Bool { get set }
    var availablePanels: [ElementInspectorPanel] { get }
}

extension ElementChildrenPanelViewModel {
    final class ChildViewModel: ElementInspectorAppearanceProviding {
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

        let element: ViewHierarchyElementReference

        lazy var animatedDisplay: Bool = relativeDepth > .zero

        init(
            element: ViewHierarchyElementReference,
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
    var summaryInfo: ViewHierarchyElementSummary {
        ViewHierarchyElementSummary(
            automaticallyAdjustIndentation: automaticallyAdjustIndentation,
            hideCollapseButton: hideCollapseButton,
            iconImage: iconImage,
            isCollapseButtonEnabled: isCollapseButtonEnabled,
            isCollapsed: isCollapsed,
            isContainer: isContainer,
            isHidden: isHidden,
            relativeDepth: relativeDepth,
            subtitle: subtitle,
            subtitleFont: subtitleFont,
            title: title,
            titleFont: titleFont
        )
    }

    var availablePanels: [ElementInspectorPanel] {
        ElementInspectorPanel.allCases(for: element)
    }

    var showDisclosureIcon: Bool { relativeDepth > .zero }

    var appearance: (transform: CGAffineTransform, alpha: CGFloat) {
        if animatedDisplay {
            return (transform: Inspector.sharedInstance.appearance.elementInspector.panelInitialTransform, alpha: .zero)
        }
        return (transform: .identity, alpha: 1)
    }

    var isHidden: Bool {
        guard let parent = parent as? ElementChildrenPanelTableViewCellViewModelProtocol else {
            return parent?.isCollapsed == true
        }

        return parent.isCollapsed == true || parent.isHidden == true
    }

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

    private var automaticallyAdjustIndentation: Bool { relativeDepth > .zero }

    private var title: String? { relativeDepth > .zero ? element.elementName : nil }

    private var subtitle: String? { relativeDepth > .zero ? element.shortElementDescription : element.elementDescription }

    private var titleFont: UIFont { elementInspectorAppearance.titleFont(forRelativeDepth: relativeDepth) }

    private var subtitleFont: UIFont { elementInspectorAppearance.font(forRelativeDepth: relativeDepth) }

    private var isCollapseButtonEnabled: Bool {
        relativeDepth < Inspector.sharedInstance.configuration.elementInspectorConfiguration.childrenListMaximumInteractiveDepth
    }

    private var hideCollapseButton: Bool {
        if relativeDepth == .zero { return true }

        return !isContainer
    }

    var isContainer: Bool { element.isContainer }

    private var relativeDepth: Int { element.depth - rootDepth }
}

// MARK: - Hashable

extension ElementChildrenPanelViewModel.ChildViewModel: Hashable {
    static func == (lhs: ElementChildrenPanelViewModel.ChildViewModel, rhs: ElementChildrenPanelViewModel.ChildViewModel) -> Bool {
        lhs.element.objectIdentifier == rhs.element.objectIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(element.objectIdentifier)
    }
}

// MARK: - Images

private extension ElementChildrenPanelViewModel.ChildViewModel {
    static let thumbnailImageLostConnection = IconKit.imageOfWifiExlusionMark(
        CGSize(
            width: Inspector.sharedInstance.appearance.elementInspector.horizontalMargins * 1.5,
            height: Inspector.sharedInstance.appearance.elementInspector.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)

    static let thumbnailImageIsHidden = IconKit.imageOfEyeSlashFill(
        CGSize(
            width: Inspector.sharedInstance.appearance.elementInspector.horizontalMargins * 1.5,
            height: Inspector.sharedInstance.appearance.elementInspector.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)
}
