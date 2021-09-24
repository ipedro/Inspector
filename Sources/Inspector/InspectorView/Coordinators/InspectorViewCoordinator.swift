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

@_implementationOnly import Coordinator
import UIKit

protocol InspectorViewCoordinatorSwiftUIDelegate: AnyObject {
    func inspectorViewCoordinator(_ coordinator: InspectorViewCoordinator, willFinishWith command: InspectorCommand?)
}

protocol InspectorViewCoordinatorDelegate: AnyObject {
    func inspectorViewCoordinator(_ coordinator: InspectorViewCoordinator, didFinishWith command: InspectorCommand?)
}

final class InspectorViewCoordinator: ViewCoordinator {
    typealias CommandGroupsProvider = HierarchyInspectorViewModel.CommandGroupsProvider

    weak var swiftUIDelegate: InspectorViewCoordinatorSwiftUIDelegate?

    weak var delegate: InspectorViewCoordinatorDelegate?

    let hierarchySnapshot: ViewHierarchySnapshot

    let commandGroupsProvider: CommandGroupsProvider

    private lazy var inspectorViewController: InspectorViewController = {
        let viewModel = HierarchyInspectorViewModel(
            commandGroupsProvider: commandGroupsProvider,
            snapshot: hierarchySnapshot
        )

        return InspectorViewController(viewModel: viewModel).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.modalTransitionStyle = .crossDissolve
            $0.delegate = self
        }
    }()

    init(
        snapshot: ViewHierarchySnapshot,
        commandGroups: @escaping CommandGroupsProvider
    ) {
        hierarchySnapshot = snapshot
        commandGroupsProvider = commandGroups

        super.init()
    }

    func start() -> UIViewController {
        inspectorViewController
    }

    func reloadData() {
        inspectorViewController.reloadData()
    }

    func finish() {
        finish(command: .none)
    }

    func finish(command: InspectorCommand?) {
        if let swiftUIDelegate = swiftUIDelegate {
            swiftUIDelegate.inspectorViewCoordinator(self, willFinishWith: command)
            return
        }

        if let delegate = delegate {
            inspectorViewController.dismiss(animated: true) {
                delegate.inspectorViewCoordinator(self, didFinishWith: command)
            }
            return
        }
    }
}

// MARK: - InspectorViewControllerDelegate

extension InspectorViewCoordinator: InspectorViewControllerDelegate {
    func inspectorViewController(_ viewController: InspectorViewController, didSelect command: InspectorCommand?) {
        finish(command: command)
    }

    func inspectorViewControllerDidFinish(_ viewController: InspectorViewController) {
        finish()
    }
}
