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

// MARK: - CustomStringConvertible

extension ViewHierarchyLayer: CustomStringConvertible {
    var description: String {
        guard name.contains(",+") || name.contains(",-") else {
            return name
        }

        let components = name.components(separatedBy: ",")

        var additions = [String]()
        var exclusions = [String]()

        components.forEach {
            if $0 == components.first {
                additions.append($0)
            }

            if $0.first == "+" {
                additions.append(String($0.dropFirst()))
            }

            if $0.first == "-" {
                exclusions.append(String($0.dropFirst()))
            }
        }

        var displayName = String()

        additions.enumerated().forEach { index, name in
            if index == 0 {
                displayName = name
                return
            }

            if index == additions.count - 1 {
                displayName += " and \(name)"
            }
            else {
                displayName += ", \(name)"
            }
        }

        guard exclusions.isEmpty == false else {
            return displayName
        }

        exclusions.enumerated().forEach { index, name in
            if index == 0 {
                displayName += " excl․ \(name)"
                return
            }

            if index == additions.count - 1 {
                displayName += " and \(name)"
            }
            else {
                displayName += ", \(name)"
            }
        }

        return displayName
    }
}
