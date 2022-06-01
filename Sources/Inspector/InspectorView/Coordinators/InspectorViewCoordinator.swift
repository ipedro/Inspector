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

typealias CommandGroupsProvider = () -> CommandGroups?

struct InspectorViewDependencies {
    var snapshot: ViewHierarchySnapshot
    var shouldAnimateKeyboard: Bool
    var commandGroupsProvider: CommandGroupsProvider
}

final class InspectorViewCoordinator: Coordinator<InspectorViewDependencies, UIViewController, UIViewController>, DataReloadingProtocol {
    weak var swiftUIDelegate: InspectorViewCoordinatorSwiftUIDelegate?

    weak var delegate: InspectorViewCoordinatorDelegate?

    private lazy var inspectorViewController: InspectorViewController = {
        let viewModel = HierarchyInspectorViewModel(
            commandGroupsProvider: dependencies.commandGroupsProvider,
            snapshot: dependencies.snapshot,
            shouldAnimateKeyboard: dependencies.shouldAnimateKeyboard
        )

        return InspectorViewController(viewModel: viewModel).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.modalTransitionStyle = .crossDissolve
            $0.delegate = self
        }
    }()

    override func loadContent() -> UIViewController? {
        inspectorViewController
    }
    
    func reloadData() {
        inspectorViewController.reloadData()
    }
    
    func finish(command: InspectorCommand?) {
        if let swiftUIDelegate = swiftUIDelegate {
            swiftUIDelegate.inspectorViewCoordinator(self, willFinishWith: command)
            return
        }

        delegate?.inspectorViewCoordinator(self, didFinishWith: command)
    }
}

// MARK: - InspectorViewControllerDelegate

extension InspectorViewCoordinator: InspectorViewControllerDelegate {
    func inspectorViewController(_ viewController: InspectorViewController, didSelect command: InspectorCommand?) {
        finish(command: command)
    }

    func inspectorViewControllerDidFinish(_ viewController: InspectorViewController) {
        finish(command: .none)
    }
}
