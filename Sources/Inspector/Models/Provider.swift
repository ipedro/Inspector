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

public extension Inspector {
    /// Evaluates objects of a given type.
    typealias Handler<Type> = Provider<Type, Void>

    /// Transforms objects from a given type to another object from a different type.
    struct Provider<From, To>: Hashable {
        private let identifier = UUID()

        private let closure: (From) -> To

        public init(closure: @escaping (From) -> To) {
            self.closure = closure
        }

        public static func == (lhs: Provider<From, To>, rhs: Provider<From, To>) -> Bool {
            lhs.identifier == rhs.identifier
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
}

extension Inspector.Provider where To == Void {
    /// Call when you need the handler to evaluate the object.
    func handle(_ sender: From) {
        closure(sender)
    }
}

extension Inspector.Provider where From: Any, To: Any {
    /// Call when you need to resolve the current value for the given object.
    func value(for sender: From) -> To {
        closure(sender)
    }
}

extension Inspector.Provider where From == Void {
    /// Call when you need to resolve the current value.
    var value: To {
        closure(())
    }
}

// MARK: - Typealiases

typealias ViewHierarchyColorScheme = Inspector.Provider<UIView, UIColor>

public extension Inspector {
    typealias ElementIconProvider = Provider<UIView, UIImage?>
    typealias ViewHierarchyColorScheme = Provider<UIView, UIColor?>
}
