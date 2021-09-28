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

typealias ViewHierarchyActionHandler = (ViewHierarchyElement, ViewHierarchyAction) -> Void

@available(iOS 13.0, *)
extension UIMenu {
    convenience init?(
        with reference: ViewHierarchyElement,
        initialMenus: [UIMenuElement] = [],
        includeActions: Bool = true,
        options: UIMenu.Options = .init(),
        handler: @escaping ViewHierarchyActionHandler
    ) {
        var menus: [UIMenuElement] = initialMenus

        if includeActions, let actionsMenu = UIMenu.actionsMenu(reference: reference, options: .displayInline, handler: handler) {
            menus.append(actionsMenu)
        }

        if !reference.children.isEmpty {
            if #available(iOS 14.0, *) {
                let childrenMenu = UIDeferredMenuElement { completion in
                    if let menu = Self.childrenMenu(reference: reference, handler: handler) {
                        completion([menu])
                    }
                    else {
                        completion([])
                    }
                }
                menus.append(childrenMenu)
            }
            else if let childrenMenu = Self.childrenMenu(reference: reference, handler: handler) {
                menus.append(childrenMenu)
            }
        }

        self.init(
            title: reference.elementName,
            image: nil,
            identifier: nil,
            options: options,
            children: menus
        )
    }

    private static func childrenMenu(reference: ViewHierarchyElement, options: UIMenu.Options = .init(), handler: @escaping ViewHierarchyActionHandler) -> UIMenu? {
        guard !reference.children.isEmpty else { return nil }

        return UIMenu(
            title: Texts.children.appending(" (\(reference.children.count))"),
            image: nil,
            identifier: nil,
            options: options,
            children: reference.children.compactMap {
                UIMenu(with: $0, handler: handler)
            }
        )
    }

    private static func actionsMenu(reference: ViewHierarchyElement, options: UIMenu.Options = .init(), handler: @escaping ViewHierarchyActionHandler) -> UIMenu? {
        let groupedCases = ViewHierarchyAction.groupedCases(for: reference)

        guard !groupedCases.isEmpty else { return nil }

        return UIMenu(
            title: "",
            options: options,
            children: groupedCases.compactMap { group in
                guard group.isEmpty == false else { return nil }

                return UIMenu(
                    title: "",
                    image: nil,
                    identifier: nil,
                    options: .displayInline,
                    children: group.map { action in
                        UIAction(title: action.title, image: action.image) {
                            _ in handler(reference, action)
                        }
                    }
                )
            }
        )
    }

}
