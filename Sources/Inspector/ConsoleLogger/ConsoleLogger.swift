//  Copyright (c) 2022 Pedro Almeida
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


import Foundation

// MARK: - Console Utils

public func printViewHierarchyDescription() {
    Inspector.sharedInstance.console.printViewHierarchyDescription()
}

public func printViewHierarchyDescription(of object: NSObject?) {
    Inspector.sharedInstance.console.printViewHierarchyDescription(of: object)
}

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
