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
@_implementationOnly import CoordinatorAPI
import UIKit

struct ManagerDependencies {
    var configuration: InspectorConfiguration
    var coordinatorFactory: ViewHierarchyCoordinatorFactoryProtocol.Type
    var customization: InspectorCustomizationProviding?
    var viewHierarchy: ViewHierarchyRepresentable
    var swiftUIhost: InspectorSwiftUIHost?
}

final class Manager: Coordinator<ManagerDependencies, OperationQueue, Void> {
    var snapshot: ViewHierarchySnapshot { viewHierarchyCoordinator.latestSnapshot() }
    var keyWindow: UIWindow? { dependencies.viewHierarchy.keyWindow }
    var catalog: ViewHierarchyElementCatalog { viewHierarchyCoordinator.dependencies.catalog }
    
    lazy var keyCommandsStore = ExpirableStore<[UIKeyCommand]>(lifespan: dependencies.configuration.snapshotExpirationTimeInterval)

    func dismissInspectorViewIfNeeded(_ closure: @escaping () -> Void) {
        let coordinators = children.compactMap { $0 as? InspectorViewCoordinator }

        if coordinators.isEmpty { return closure() }

        for coordinator in coordinators {
            coordinator.removeFromParent()
            coordinator.start().dismiss(animated: false)
        }

        DispatchQueue.main.async(execute: closure)
    }

    private(set) lazy var viewHierarchyCoordinator: ViewHierarchyCoordinator = {
        let coordinator = dependencies.coordinatorFactory.makeCoordinator(
            with: dependencies.viewHierarchy.windows,
            operationQueue: operationQueue,
            customization: dependencies.customization,
            defaultLayers: dependencies.configuration.defaultLayers.sorted(by: <)
        )
        coordinator.delegate = self
        return coordinator
    }()

    // MARK: - Init

    override init(
        _ dependencies: ManagerDependencies,
        presentedBy presenter: OperationQueue,
        parent: CoordinatorProtocol? = nil,
        children: [CoordinatorProtocol] = []
    ) {
        super.init(
            dependencies,
            presentedBy: presenter,
            parent: parent,
            children: children
        )

        if dependencies.configuration.enableLayoutSubviewsSwizzling {
            UIView.startSwizzling()
        }
    }

    deinit {
        operationQueue.cancelAllOperations()

        children.forEach { child in
            (child as? DismissablePresentationProtocol)?.dismissPresentation(animated: true)
            child.removeFromParent()
        }
    }

    override func loadContent() -> Void? {
        viewHierarchyCoordinator.start()
    }
}

// MARK: - AsyncOperationProtocol

extension Manager: AsyncOperationProtocol {
    func asyncOperation(name: String = #function, execute closure: @escaping Closure) {
        operationQueue.addOperation(
            MainThreadAsyncOperation(name: name, closure: closure)
        )
    }
}
