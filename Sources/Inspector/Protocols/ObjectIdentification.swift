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

// MARK: - ObjectIdentification

protocol ObjectIdentification {
    /// A unique identifier for the instance object.
    var objectIdentifier: ObjectIdentifier { get }

    /// Overridden by subclasses to substitute a class other than its own during coding.
    var classForCoder: AnyClass { get }

    /// Returns the class object for the receiver’s superclass.
    var superclass: AnyClass? { get }

    /// Returns the class objects for the receiver’s class hierarchy.
    var classes: [AnyClass] { get }
}

extension ObjectIdentification {
    var className: String {
        String(describing: classForCoder)
    }

    var superclassName: String? {
        guard let superclass = superclass else { return nil }
        return String(describing: superclass)
    }

    var isInternalType: Bool {
        className.starts(with: "_")
    }

    var classNames: [String] {
        classes.map { String(describing: $0) }
    }

    var classNameWithoutQualifiers: String {
        guard let nameWithoutQualifiers = className.split(separator: "<").first else {
            return className
        }

        return String(nameWithoutQualifiers)
    }

    var isSystemContainer: Bool {
        let classNameWithoutQualifiers = classNameWithoutQualifiers

        if classNameWithoutQualifiers.starts(with: "_UI") { return true }

        return Inspector.configuration.knownSystemContainers.contains(classNameWithoutQualifiers)
    }
}
