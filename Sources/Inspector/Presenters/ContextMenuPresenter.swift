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

final class ContextMenuPresenter: NSObject, UIContextMenuInteractionDelegate {
    private let configurationProvider: (UIContextMenuInteraction) -> UIContextMenuConfiguration?
    private var store: [ObjectIdentifier: UIContextMenuInteraction] = [:]

    init(configurationProvider: @escaping (UIContextMenuInteraction) -> UIContextMenuConfiguration?) {
        self.configurationProvider = configurationProvider
    }

    func addInteraction(to view: UIView) {
        let key = view.objectIdentifier

        guard
            view.canHostContextMenuInteraction,
            view.allParents.filter({ $0 is InternalViewProtocol }).isEmpty,
            store[key] == nil
        else {
            return
        }

        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)
        store[key] = interaction
    }

    func removeInteraction(from view: UIView) {
        let key = view.objectIdentifier
        guard let interaction = store[key] else { return }
        view.removeInteraction(interaction)
        store[key] = nil
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?
    {
        configurationProvider(interaction)
    }
}
