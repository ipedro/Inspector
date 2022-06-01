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

extension Manager: InspectorViewCoordinatorDelegate {
    func inspectorViewCoordinator(_ coordinator: InspectorViewCoordinator,
                                  didFinishWith command: InspectorCommand?)
    {
        coordinator.presenter.dismiss(animated: true) { [weak self] in
            coordinator.removeFromParent()
            guard let self = self else { return }
            self.execute(command)
        }
    }
}

extension Manager: InspectorViewCoordinatorSwiftUIDelegate {
    func inspectorViewCoordinator(_ coordinator: InspectorViewCoordinator,
                                  willFinishWith command: InspectorCommand?)
    {
        dependencies.swiftUIhost?.insectorViewWillFinishPresentation()
        coordinator.removeFromParent()
        execute(command)
    }
}

extension Manager {
    private func execute(_ command: InspectorCommand?) {
        guard let command = command else { return }

        asyncOperation { [weak self] in
            switch command {
            case let .execute(closure):
                closure()

            case let .inspect(reference):
                guard let self = self, let sourceView = reference.underlyingView else { return }

                self.startElementInspectorCoordinator(
                   for: reference,
                   panel: .none,
                   from: sourceView,
                   animated: true
                )
            }
        }
    }

    func presentInspector(animated: Bool) {
        guard let presenter = dependencies.viewHierarchy.topPresentedViewController else { return }
        return presentInspector(animated: animated, from: presenter)
    }

    func presentInspector(animated: Bool, from presenter: UIViewController) {
        guard let coordinator = makeInspectorViewCoordinator(presentedBy: presenter) else {
            return
        }

        for case let previousCoordinator as InspectorViewCoordinator in children {
            previousCoordinator.removeFromParent()
        }

        addChild(coordinator)

        let inspectorViewController = coordinator.start()

        presenter.present(inspectorViewController, animated: animated)
    }

    func makeInspectorViewCoordinator(presentedBy presenter: UIViewController) -> InspectorViewCoordinator? {
        guard let snapshot = snapshot else { return nil }

        let coordinator = InspectorViewCoordinator(
            .init(
                snapshot: snapshot,
                shouldAnimateKeyboard: dependencies.swiftUIhost == nil,
                commandGroupsProvider: { [weak self] in
                    guard let self = self else { return .none }
                    return self.commandGroups
                }
            ),
            presentedBy: presenter
        )

        if dependencies.swiftUIhost != nil {
            coordinator.swiftUIDelegate = self
        } else {
            coordinator.delegate = self
        }

        return coordinator
    }
}
