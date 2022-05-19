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

typealias Closure = () -> Void

public final class Inspector {
    // MARK: - Public Properties

    public var configuration: InspectorConfiguration = .default {
        didSet {
            restartIfNeeded()
        }
    }

    public var customization: InspectorCustomizationProviding? {
        didSet {
            restartIfNeeded()
        }
    }

    // MARK: - Private Properties

    private enum State {
        case idle, started
    }

    private(set) var manager: Manager?

    private var state: State = .idle

    // MARK: - Internal Properties

    static let sharedInstance = Inspector()

    let appearance = InspectorAppearance()

    private(set) lazy var console = ConsoleLogger { [weak self] in
        self?.manager?.snapshot
    }

    private(set) var contextMenuPresenter: ContextMenuPresenter?

    var swiftUIHost: InspectorSwiftUIHost? {
        didSet {
            restartIfNeeded()
        }
    }

    func start() {
        guard state == .idle else { return }
        setup()
        manager?.start()
        state = .started
    }

    func stop() {
        guard state == .started else { return }
        manager = .none
        contextMenuPresenter = .none
        state = .idle
    }

    private func restartIfNeeded() {
        if state == .started { restart() }
    }

    private func restart() {
        stop()
        start()
    }

    private func setup() {
        manager = Manager(
            .init(
                configuration: configuration,
                coordinatorFactory: ViewHierarchyCoordinatorFactory.self,
                customization: customization,
                viewHierarchy: ViewHierarchy.application
            ),
            presentedBy: OperationQueue.main
        )

        contextMenuPresenter = ContextMenuPresenter { [weak self] interaction in
            guard
                let self = self,
                let sourceView = interaction.view,
                let snapshot = self.manager?.snapshot?.root.viewHierarchy,
                let element = snapshot.first(where: { $0.underlyingView === interaction.view })
            else {
                return .none
            }
            return .contextMenuConfiguration(
                with: element,
                includeActions: true
            ) { [weak self] reference, action in
                guard let self = self else { return }
                self.manager?.perform(
                    action: action,
                    with: reference,
                    from: sourceView
                )
            }
        }
    }
}

// MARK: - Console Utils

struct ConsoleLogger {
    let snapshotProvider: () -> ViewHierarchySnapshot?

    enum Error: Swift.Error, CustomStringConvertible {
        case snapshotUnavailable
        case objectIsNil
        case couldNotFindObject

        var description: String {
            switch self {
            case .snapshotUnavailable: return "Couldn't capture the view hierarchy. Make sure Inspector.start() was called"
            case .couldNotFindObject: return "Couldn't find the object in the view hierarchy"
            case .objectIsNil: return "The object is nil"
            }
        }
    }

    func printViewHierarchyDescription() {
        switch takeSnapshot() {
        case let .success(snapshot):
            print(snapshot.root.viewHierarchyDescription)
        case let .failure(error):
            print(error.description)
        }
    }

    func printViewHierarchyDescription(of object: NSObject?) {
        switch takeSnapshot() {
        case let .success(snapshot):
            guard let object = object else { return print(Error.objectIsNil) }
            guard let reference = snapshot.containsReference(for: object) else { return print(Error.couldNotFindObject) }
            print(reference.viewHierarchyDescription)
        case let .failure(error):
            print(error.description)
        }
    }

    private func takeSnapshot() -> Result<ViewHierarchySnapshot, Error> {
        guard let snapshot = snapshotProvider() else {
            return .failure(.snapshotUnavailable)
        }
        return .success(snapshot)
    }

    private func print(_ message: CustomStringConvertible) {
        Swift.print(message.description)
    }
}

// MARK: - Presentation

extension Inspector {
    func present(animated: Bool = true) {
        manager?.presentInspector(animated: animated)
    }
}

// MARK: - Element

extension Inspector {
    func isInspecting(_ view: UIView) -> Bool {
        view.allSubviews.contains { $0 is LayerViewProtocol }
    }

    func inspect(_ view: UIView, animated: Bool = true) {
        manager?.startElementInspectorCoordinator(for: view, panel: .none, from: view, animated: animated)
    }
}

// MARK: - View Hierarchy Layer

extension Inspector {
    func isInspecting(_ layer: Inspector.ViewHierarchyLayer) -> Bool {
        manager?.isShowingLayer(layer) ?? false
    }

    func inspect(_ layer: Inspector.ViewHierarchyLayer) {
        manager?.toggleLayer(layer)
    }

    func toggle(_ layer: Inspector.ViewHierarchyLayer) {
        manager?.toggleLayer(layer)
    }

    func toggleAllLayers() {
        manager?.toggleAllLayers()
    }

    func stopInspecting(_ layer: Inspector.ViewHierarchyLayer) {
        manager?.removeLayer(layer)
    }

    func removeAllLayers() {
        manager?.removeAllLayers()
    }
}

// MARK: - KeyCommands

extension Inspector {
    var keyCommands: [UIKeyCommand]? {
        manager?.keyCommands
    }
}

// MARK: - Public API

public extension Inspector {
    static func start() {
        sharedInstance.start()
    }

    static func stop() {
        sharedInstance.stop()
    }

    static func printViewHierarchyDescription() {
        sharedInstance.console.printViewHierarchyDescription()
    }

    static func printViewHierarchyDescription(of object: NSObject?) {
        sharedInstance.console.printViewHierarchyDescription(of: object)
    }

    static func present(animated: Bool = true) {
        sharedInstance.present(animated: animated)
    }

    static func isInspecting(_ view: UIView) -> Bool {
        sharedInstance.isInspecting(view)
    }

    static func inspect(_ view: UIView, animated: Bool = true) {
        sharedInstance.inspect(view, animated: animated)
    }

    static func isInspecting(_ layer: Inspector.ViewHierarchyLayer) -> Bool {
        sharedInstance.isInspecting(layer)
    }

    static func inspect(_ layer: Inspector.ViewHierarchyLayer) {
        sharedInstance.inspect(layer)
    }

    static func toggle(_ layer: Inspector.ViewHierarchyLayer) {
        sharedInstance.toggle(layer)
    }

    static func toggleAllLayers() {
        sharedInstance.toggleAllLayers()
    }

    static func stopInspecting(_ layer: Inspector.ViewHierarchyLayer) {
        sharedInstance.stopInspecting(layer)
    }

    static func removeAllLayers() {
        sharedInstance.removeAllLayers()
    }

    static var keyCommands: [UIKeyCommand]? {
        sharedInstance.keyCommands
    }

    static func setConfiguration(_ configuration: InspectorConfiguration?) {
        sharedInstance.configuration = configuration ?? .default
    }

    static func setCustomization(_ customization: InspectorCustomizationProviding?) {
        sharedInstance.customization = customization
    }
}
