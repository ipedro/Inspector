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

@available(iOS 13.0, *)
extension Inspector.Manager: UIContextMenuInteractionDelegate {
    func addInteraction(to view: UIView) {
        let viewIdentifier = view.objectIdentifier

        guard isContextMenuInteractionSetup[viewIdentifier] == nil else { return }

        if view.canHostContextMenuInteraction {
            view.addInteraction(UIContextMenuInteraction(delegate: self))
            isContextMenuInteractionSetup[viewIdentifier] = true
        }
        else {
            isContextMenuInteractionSetup[viewIdentifier] = false
            print("🧬 Ignoring \(view._className)")
        }
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard
            let interactionView = interaction.view,
            let viewHierarchy = viewHierarchySnapshot?.root.viewHierarchy,
            let element = viewHierarchy.first(where: { $0.underlyingView === interaction.view })
        else {
            return .none
        }
        return .contextMenuConfiguration(
            with: element,
            includeActions: true
        ) { [weak self] reference, action in
            self?.perform(
                action: action,
                with: reference,
                from: interactionView
            )
        }
    }
}
