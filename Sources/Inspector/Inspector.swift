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

typealias Closure = () -> Void

public enum Inspector {
    static let manager = Inspector.Manager()

    public static var console: Console? {
        guard let viewHierarchySnapshot = manager.viewHierarchySnapshot else { return nil }

        return try? Console(snapshot: viewHierarchySnapshot)
    }

    public static var configuration = InspectorConfiguration(
        isSwizzlingEnabled: {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }()
    )

    public static var host: InspectorHost? {
        get { manager.host }
        set { manager.host = newValue }
    }

    public static func start() {
        _ = manager
    }

    public static func finish() {
        manager.finish()
    }

    public static func restart() {
        manager.reset()
    }
}

// MARK: - Presentation

public extension Inspector {
    static func present(animated: Bool = true) {
        manager.presentInspector(animated: animated)
    }
}

// MARK: - Element

public extension Inspector {
    static func isInspecting(_ view: UIView) -> Bool {
        view.allSubviews.contains { $0 is LayerViewProtocol }
    }

    static func inspect(_ view: UIView, animated: Bool = true) {
        manager.startElementInspectorCoordinator(for: view, panel: .none, from: view, animated: animated)
    }
}

// MARK: - View Hierarchy Layer

public extension Inspector {
    static func isInspecting(_ layer: Inspector.ViewHierarchyLayer) -> Bool {
        manager.isShowingLayer(layer)
    }

    static func inspect(_ layer: Inspector.ViewHierarchyLayer) {
        manager.toggleLayer(layer)
    }

    static func toggle(_ layer: Inspector.ViewHierarchyLayer) {
        manager.toggleLayer(layer)
    }

    static func toggleAllLayers() {
        manager.toggleAllLayers()
    }

    static func stopInspecting(_ layer: Inspector.ViewHierarchyLayer) {
        manager.removeLayer(layer)
    }

    static func removeAllLayers() {
        manager.removeAllLayers()
    }
}

// MARK: - KeyCommands

public extension Inspector {
    static var keyCommands: [UIKeyCommand] {
        manager.keyCommands
    }
}
