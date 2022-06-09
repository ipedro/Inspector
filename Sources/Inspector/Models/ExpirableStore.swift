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

struct ExpirableStore<Value>: ExpirableProtocol {
    private let lifespan: TimeInterval
    
    private(set) var expirationDate : Date
    
    private var _wrappedValue: Value?

    var wrappedValue: Value? {
        get {
            isValid ? _wrappedValue : .none
        }
        set {
            _wrappedValue = newValue
            expirationDate = Self.makeExpirationDate(lifespan)
        }
    }

    init(_ value: Value? = .none, lifespan: TimeInterval) {
        expirationDate = Self.makeExpirationDate(lifespan)
        _wrappedValue = value
        self.lifespan = lifespan
    }
    
    private static func makeExpirationDate(_ lifespan: TimeInterval) -> Date {
        Date().addingTimeInterval(lifespan)
    }
}
