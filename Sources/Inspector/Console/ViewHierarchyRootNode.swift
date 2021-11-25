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

extension Console {
    public struct ViewHierarchyRootNode: ConsoleElementNode {
        public typealias Child = Inspector.Console.ViewHierarchyElementNode

        public typealias Element = UIWindow

        public var element: UIWindow? {
            keyWindow.underlyingView as? UIWindow
        }

        fileprivate let keyWindow: ViewHierarchyElementReference

        init?(reference: ViewHierarchyRoot) {
            guard let keyWindow = reference.keyWindow else { return nil }

            self.keyWindow = keyWindow
        }

        public var debugDescription: String { .newLine }

        public func printViewHierarchy() {
            Swift.print(keyWindow.viewHierarchyDescription)
        }

        public func children() -> Inspector.ConsoleQuery<Inspector.Console.ViewHierarchyElementNode> {
            .init(keyWindow.children.map { Console.ViewHierarchyElementNode(reference: $0) })
        }
    }
}

public extension Optional where Wrapped == Inspector.Console.ViewHierarchyRootNode {
    func printViewHierarchy() {
        switch self {
        case .none:
            Swift.print("Not found")
        case .some(let wrapped):
            wrapped.printViewHierarchy()
        }
    }

    public func children() -> Inspector.ConsoleQuery<Inspector.Console.ViewHierarchyElementNode> {
        switch self {
        case .none:
            return .init([])
        case .some(let wrapped):
            return wrapped.children()
        }
    }
}
