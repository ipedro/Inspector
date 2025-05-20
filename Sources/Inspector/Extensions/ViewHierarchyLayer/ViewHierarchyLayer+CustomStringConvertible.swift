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

extension ViewHierarchyLayer: CustomStringConvertible {
    var description: String {
        guard name.contains(",+") || name.contains(",-") else {
            return name
        }

        let components = name.components(separatedBy: ",")

        var additions = [String]()
        var exclusions = [String]()

        for component in components {
            if component == components.first {
                additions.append(component)
            }

            if component.first == "+" {
                additions.append(String(component.dropFirst()))
            }

            if component.first == "-" {
                exclusions.append(String(component.dropFirst()))
            }
        }

        var displayName = String()

        for (index, name) in additions.enumerated() {
            if index == 0 {
                displayName = name
                continue
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

        for (index, name) in exclusions.enumerated() {
            if index == 0 {
                displayName += " excl․ \(name)"
                continue
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
