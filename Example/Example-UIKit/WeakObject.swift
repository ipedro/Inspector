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
//  THE SOFTWARE IS PROVIDED "AS IS", WorITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

final class Weak<Object: AnyObject>: Hashable {
    private let objectIdentifier: ObjectIdentifier
    weak var weakReference: Object?

    init(_ object: Object) {
        objectIdentifier = ObjectIdentifier(object)
        weakReference = object
    }

    convenience init?(_ object: Object?) {
        guard let object = object else { return nil }
        self.init(object)
    }

    static func == (lhs: Weak<Object>, rhs: Weak<Object>) -> Bool {
        lhs.objectIdentifier == rhs.objectIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(objectIdentifier)
    }
}
