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

typealias ViewHierarchyActionHandler = (ViewHierarchyReference, ViewHierarchyAction) -> Void

@available(iOS 13.0, *)
extension UIMenu {
    convenience init?(
        with reference: ViewHierarchyReference,
        includeActions: Bool = true,
        handler: @escaping ViewHierarchyActionHandler
    ) {
        var menus: [UIMenuElement] = []

        if includeActions, let actionsMenu = UIMenu.actionsMenu(reference: reference, options: .displayInline, handler: handler) {
            menus.append(actionsMenu)
        }

        let copyMenu = UIMenu.copyMenu(reference: reference, options: .displayInline)
        menus.append(copyMenu)

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
            children: menus
        )
    }

    private static func childrenMenu(reference: ViewHierarchyReference, options: UIMenu.Options = .init(), handler: @escaping ViewHierarchyActionHandler) -> UIMenu? {
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

    private static func actionsMenu(reference: ViewHierarchyReference, options: UIMenu.Options = .init(), handler: @escaping ViewHierarchyActionHandler) -> UIMenu? {
        guard !reference.actions.isEmpty else { return nil }

        return UIMenu(
            title: "Actions",
            options: options,
            children: reference.actions.map { action in
                UIAction(title: action.title, image: action.image) { _ in
                    handler(reference, action)
                }
            }
        )
    }

    private static func copyMenu(reference: ViewHierarchyReference, options: UIMenu.Options = .init()) -> UIMenu {
        UIMenu(
            title: Texts.copy,
            image: .none,
            options: options,
            children: [
                UIAction.copyAction(
                    title: Texts.copy("Class Name"),
                    stringProvider: { reference.className }
                ),
                UIAction.copyAction(
                    title: Texts.copy("Description"),
                    stringProvider: { reference.elementDescription }
                )
            ]
        )
    }

}
