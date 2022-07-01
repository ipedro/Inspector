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

extension UIContextMenuConfiguration {
    convenience init(actionProvider: UIContextMenuActionProvider?) {
        self.init(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
    }

    static func contextMenuConfiguration(
        initialMenus: [UIMenuElement] = [],
        with element: ViewHierarchyElementReference,
        includeActions: Bool = true,
        handler: @escaping ViewHierarchyActionHandler
    ) -> UIContextMenuConfiguration? {
        var menus = initialMenus

        if let menu = UIMenu(
            with: element,
            includeActions: includeActions,
            options: .displayInline,
            handler: handler
        ) {
            menus.append(menu)
        }

        guard menus.isEmpty == false else { return nil }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                ViewHierarchyPreviewController(with: element)
            },
            actionProvider: { _ in
                UIMenu(
                    options: .displayInline,
                    children: menus
                )
            }
        )
    }
}
