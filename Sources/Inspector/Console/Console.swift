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

typealias Console = Inspector.Console

extension Inspector {
    public struct Console: ConsoleCommand {
        enum ConsoleError: Error {
            case noRoot
        }

        private let root: ViewHierarchyRoot

        private let node: ViewHierarchyRootNode

        init(snapshot: ViewHierarchySnapshot) throws {
            guard let node = ViewHierarchyRootNode(reference: snapshot.root) else { throw ConsoleError.noRoot }
            self.root = snapshot.root
            self.node = node
        }

        public func keyWindow() -> ViewHierarchyElementNode? {
            guard let keyWindow = root.keyWindow else { return nil }

            return ViewHierarchyElementNode(reference: keyWindow)
        }

        /// Show the console help
        public func help() {
            Swift.print(debugDescription)
        }

        /// Returns objects of any type in the view hierarchy.
        public func children<Object: NSObject>(of type: Object.Type) -> ConsoleQuery<ViewHierarchyElementNode>? {
            node.children().of(type: type)
        }

        public var description: String {
            root.elementDescription
        }

        public var debugDescription: String {
"""
Inspector Console
=================

Available commands:
- help()            : Show the console help
- viewHiearchy()    : The view hierarchy root, usually the key window.
- children(of:)     : Returns objects of any type in the view hierarchy.


View Hierarchy

"""
        }
    }
}
