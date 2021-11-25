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

extension NSObject {
    func propertyNames() -> [String] {
        var propertyCount: UInt32 = 0
        var propertyNames: [String] = []

        guard
            let propertyListPointer = class_copyPropertyList(type(of: self), &propertyCount),
            propertyCount > .zero
        else {
            return []
        }

        for index in 0 ..< Int(propertyCount) {
            let pointer = propertyListPointer[index]

            guard let propertyName = NSString(utf8String: property_getName(pointer)) as String?
            else { continue }

            propertyNames.append(propertyName)
        }

        free(propertyListPointer)
        return propertyNames.uniqueValues()
    }

    func safeValue(forKey key: String) -> Any? {
        let keyPath = "\(classNameWithoutQualifiers).\(key)"

        if Inspector.configuration.blockLists.propertyNames.contains(keyPath) {
            return nil
        }

        return value(forKey: key)
    }
}
