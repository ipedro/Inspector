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
        removeChild(coordinator)
        execute(command)
    }
}

extension Manager: InspectorViewCoordinatorSwiftUIDelegate {
    func inspectorViewCoordinator(_ coordinator: InspectorViewCoordinator,
                                  willFinishWith command: InspectorCommand?)
    {
        swiftUIhost?.insectorViewWillFinishPresentation()
        removeChild(coordinator)
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
                guard let self = self, let sourceView = reference.rootView else { return }

                self.startElementInspectorCoordinator(
                    for: reference,
                    with: .none,
                    animated: true,
                   from: sourceView
                )
            }
        }
    }

    @discardableResult
    func presentInspector(animated: Bool) -> UIViewController? {
        guard let hostViewController = hostViewController else { return nil }

        return presentInspector(animated: animated, in: hostViewController)
    }

    @discardableResult
    func presentInspector(animated: Bool, in presentingViewController: UIViewController) -> UIViewController? {
        guard let coordinator = makeInspectorViewCoordinator() else { return nil }

        let viewController = coordinator.start()

        presentingViewController.present(viewController, animated: animated)

        return viewController
    }

    func makeInspectorViewCoordinator() -> InspectorViewCoordinator? {
        guard let snapshot = viewHierarchySnaphost else { return nil }

        let coordinator = InspectorViewCoordinator(
            snapshot: snapshot,
            commandGroups: { [weak self] in self?.commandGroups }
        ).then {
            if swiftUIhost != nil {
                $0.swiftUIDelegate = self
            }
            else {
                $0.delegate = self
            }
        }

        addChild(coordinator)

        return coordinator
    }
}
