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
    convenience init?(
        with element: ViewHierarchyElementReference,
        initialMenus: [UIMenuElement] = [],
        includeActions: Bool = true,
        options: UIMenu.Options = .init(),
        handler: @escaping (ViewHierarchyElementReference, ViewHierarchyElementAction) -> Void
    ) {
        var menus: [UIMenuElement] = initialMenus

        if includeActions, let actionsMenu = UIMenu.actionsMenu(element: element, options: .displayInline, handler: handler) {
            menus.append(actionsMenu)
        }

        if element.isContainer {
            if #available(iOS 14.0, *) {
                let childrenMenu = UIDeferredMenuElement { completion in
                    if let menu = Self.childrenMenu(element: element, handler: handler) {
                        completion([menu])
                    }
                    else {
                        completion([])
                    }
                }
                menus.append(childrenMenu)
            }
            else if let childrenMenu = Self.childrenMenu(element: element, handler: handler) {
                menus.append(childrenMenu)
            }
        }

        self.init(
            title: element.displayName,
            image: nil,
            identifier: nil,
            options: options,
            children: menus
        )
    }

    private static func childrenMenu(element: ViewHierarchyElementReference,
                                     options: UIMenu.Options = .init(),
                                     handler: @escaping ViewHierarchyActionHandler) -> UIMenu?
    {
        guard element.isContainer else { return nil }

        return UIMenu(
            title: Texts.children.appending(" (\(element.children.count))"),
            image: nil,
            identifier: nil,
            options: options,
            children: element.children.compactMap {
                UIMenu(with: $0, handler: handler)
            }
        )
    }

    private static func actionsMenu(element: ViewHierarchyElementReference,
                                    options: UIMenu.Options = .init(),
                                    handler: @escaping ViewHierarchyActionHandler) -> UIMenu?
    {
        let groupedCases = ViewHierarchyElementAction.groupedCases(for: element)

        guard !groupedCases.isEmpty else { return nil }

        return UIMenu(
            title: Texts.actions,
            options: options,
            children: groupedCases.compactMap { group in
                guard group.isEmpty == false else { return nil }

                return UIMenu(
                    title: Texts.actions,
                    image: nil,
                    identifier: nil,
                    options: .displayInline,
                    children: group.map { action in
                        UIAction(
                            title: action.title,
                            image: action.image,
                            state: action.isOn ? .on : .off
                        ) {
                            _ in handler(element, action)
                        }
                    }
                )
            }
        )
    }
}
