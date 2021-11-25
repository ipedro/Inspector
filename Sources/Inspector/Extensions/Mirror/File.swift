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

import Foundation

extension Mirror {
    /// Use this to help you implement a custom debugDescription listing all properties of your instances
    ///
    /// - Parameters:
    ///   - subject: The instance for which to return the description.
    ///
    /// Example usage:
    ///
    ///       extension MyType: CustomDebugStringConvertible {
    ///         var debugDescription: String {
    ///           return Mirror.debugDescription(self)
    ///         }
    ///       }
    ///
    /// - Note: This will use a `Mirror` to extract the subject's type and list of properties
    ///         to include in the description
    ///
    static func debugDescription(_ subject: Any) -> String {
        let mirror = Mirror(reflecting: subject)
        return self.debugDescription(type: mirror.subjectType, children: Array(mirror.children))
    }

    /// Use this to help you implement a custom debugDescription listing custom properties of your instance
    ///
    /// - Parameters:
    ///   - type: The type for which to print the name of in the description
    ///   - properties: The list of custom properties to include in the description
    ///
    /// Example usage:
    ///
    ///       extension MyType: CustomDebugStringConvertible {
    ///           var debugDescription: String {
    ///               return Mirror.debugDescription(type(of: self), [
    ///                   "name": name,
    ///                   "color": color,
    ///                   "ownerName": owner?.name as Any
    ///               ])
    ///           }
    ///       }
    ///
    static func debugDescription(_ type: Any.Type,
    _ properties: KeyValuePairs<String?, Any> = [:]) -> String {
        let children = properties.map({ (label: $0.key, value: $0.value) })
        return self.debugDescription(type: type, children: children)
    }

    private static func debugDescription(type: Any.Type, children: [Mirror.Child]) -> String {
        let props = children.map { (prop: Mirror.Child) -> String in
            let value = String(describing: prop.value)
            // for values on multiple lines, also add indentation to all lines except the first
            let desc = value.replacingOccurrences(of: "\n", with: "\n  ")
            return "  \(prop.label ?? "-"): \(desc)"
        }
        return "\(type)(\n\(props.joined(separator: ",\n"))\n)"
    }
}
