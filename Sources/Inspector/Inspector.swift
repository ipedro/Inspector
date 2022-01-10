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
    
    public static var configuration: InspectorConfiguration = .default

    public static var host: InspectorHost? {
        get { manager.host }
        @available(*, deprecated, message: "Instead of setting host, prefer calling `start(host:configuration:)`")
        set {
            guard let newHost = newValue else { return manager.finish() }
            start(host: newHost)
        }
    }

    public static var isStarted: Bool {
        manager.host != nil
    }

    public static func start(host: InspectorHost, configuration: InspectorConfiguration = .default) {
        self.configuration = configuration
        self.manager.host = host
    }

    #if canImport(SwiftUI)
    // MARK: - SwiftUI
    static func start(swiftUIhost: InspectorSwiftUIHost, configuration: InspectorConfiguration = .default) {
        self.configuration = configuration
        self.manager.swiftUIhost = swiftUIhost
    }
    #endif

    public static func finish() {
        manager.finish()
    }

    public static func restart() {
        manager.reset()
    }
}

// MARK: - Utils

public extension Inspector {
    static func printViewHierarchyDescription() {
        printViewHierarchyDescription(of: nil)
    }
    
    static func printViewHierarchyDescription(of object: NSObject?) {
        print(viewHierarchyDescription(of: object) ?? "No snaphsot available")
    }
    
    static func viewHierarchyDescription(of object: NSObject? = nil) -> String? {
        guard let root = manager.viewHierarchySnapshot?.root else { return nil }
        
        guard let object = object else { return root.viewHierarchyDescription }
        
        return root.viewHierarchy.first(where: { $0.underlyingObject === object })?.viewHierarchyDescription
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
