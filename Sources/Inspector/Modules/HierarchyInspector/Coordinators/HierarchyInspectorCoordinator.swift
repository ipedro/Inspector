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

protocol HierarchyInspectorCoordinatorDelegate: AnyObject {
    func hierarchyInspectorCoordinator(_ coordinator: HierarchyInspectorCoordinator,
                                       didFinishWith command: HierarchyInspectorCommand?)
}

final class HierarchyInspectorCoordinator: NSObject {
    typealias CommandGroupsProvider = HierarchyInspectorViewModel.CommandGroupsProvider

    weak var delegate: HierarchyInspectorCoordinatorDelegate?

    let hierarchySnapshot: ViewHierarchySnapshot

    let commandGroupsProvider: CommandGroupsProvider

    private lazy var hierarchyInspectorViewController: HierarchyInspectorViewController = {
        let viewModel = HierarchyInspectorViewModel(
            commandGroupsProvider: commandGroupsProvider,
            snapshot: hierarchySnapshot
        )

        return HierarchyInspectorViewController.create(viewModel: viewModel).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.modalTransitionStyle = .crossDissolve
            $0.delegate = self
        }
    }()

    init(
        hierarchySnapshot: ViewHierarchySnapshot,
        commandGroupsProvider: @escaping CommandGroupsProvider
    ) {
        self.hierarchySnapshot = hierarchySnapshot
        self.commandGroupsProvider = commandGroupsProvider
    }

    func start() -> UIViewController {
        hierarchyInspectorViewController
    }

    func reloadData() {
        hierarchyInspectorViewController.reloadData()
    }

    func finish(with command: HierarchyInspectorCommand? = nil) {
        hierarchyInspectorViewController.dismiss(animated: true) {
            self.delegate?.hierarchyInspectorCoordinator(self, didFinishWith: command)
        }
    }
}

// MARK: - HierarchyInspectorViewControllerDelegate

extension HierarchyInspectorCoordinator: HierarchyInspectorViewControllerDelegate {
    func hierarchyInspectorViewController(_ viewController: HierarchyInspectorViewController,
                                          didSelect command: HierarchyInspectorCommand?)
    {
        finish(with: command)
    }

    func hierarchyInspectorViewControllerDidFinish(_ viewController: HierarchyInspectorViewController) {
        finish()
    }
}
