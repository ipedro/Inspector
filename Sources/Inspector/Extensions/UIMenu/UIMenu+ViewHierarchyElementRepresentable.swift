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

typealias ViewHierarchyActionHandler = (ViewHierarchyElementReference, ViewHierarchyElementAction) -> Void

extension UIMenu {
    private static var iconProvider: ViewHierarchyElementIconProvider? {
        Inspector.sharedInstance.manager?.catalog.iconProvider
    }

    convenience init?(
        with element: ViewHierarchyElementReference,
        initialMenus: [UIMenuElement] = [],
        includeActions: Bool = true,
        options: UIMenu.Options = .displayInline,
        handler: @escaping (ViewHierarchyElementReference, ViewHierarchyElementAction) -> Void
    ) {
        self.init(
            title: options == .displayInline ? "" : element.displayName,
            image: Self.iconProvider?.value(for: element.underlyingObject)?.resized(.init(24)),
            options: options,
            children: {
                var menus: [UIMenuElement] = initialMenus

                if includeActions {
                    let actionMenus = UIMenu.actionMenus(
                        element: element,
                        options: .displayInline,
                        handler: handler
                    )
                    menus.append(contentsOf: actionMenus)
                }

                if let childrenMenu = Self.childrenMenu(
                    element: element,
                    handler: handler
                ) {
                    menus.append(childrenMenu)
                }

                return menus
            }()
        )
    }

    private static func childrenMenu(element: ViewHierarchyElementReference,
                                     options: UIMenu.Options = .init(),
                                     handler: @escaping ViewHierarchyActionHandler) -> UIMenu?
    {
        guard element.isContainer else { return nil }

        return UIMenu(
            title: Texts.children.appending(" (\(element.children.count))"),
            image: .elementChildrenPanel,
            options: options,
            children: [UIDeferredMenuElement { completion in
                completion(
                    element.children.compactMap {
                        UIMenu(with: $0, options: .init(), handler: handler)
                    }
                )
            }]
        )
    }

    private static func actionMenus(element: ViewHierarchyElementReference,
                                    options: UIMenu.Options = .init(),
                                    handler: @escaping ViewHierarchyActionHandler) -> [UIMenu]
    {
        ViewHierarchyElementAction
            .actionGroups(for: element)
            .map { group in
                UIMenu(
                    title: group.title,
                    image: group.image,
                    options: group.inline ? .displayInline : .init(),
                    children: group.actions.map { action in
                        UIAction(
                            title: action.title,
                            image: action.image,
                            state: action.isOn ? .on : .off
                        ) { _ in
                            handler(element, action)
                        }
                    }
                )
            }
    }
}
