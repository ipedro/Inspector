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

extension Inspector {
    public struct ConsoleQuery<Result>: ConsoleCommand {
        let results: [Result]

        init(_ results: [Result]) {
            self.results = results
        }

        public var count: Int { results.count }

        public var debugDescription: String {
            results.enumerated().map { index, element in
                let components = String(describing: element).split(separator: ";").map { substring in
                    String(substring).replacingOccurrences(of: ">)", with: "\n>")
                }
                return "\(String(index)). \(components.joined(separator: .newLine))"
            }
            .joined(separator: .newLine)
        }

        public var first: Result? {
            results.first
        }

        public var last: Result? {
            results.last
        }
    }
}

public extension Inspector.ConsoleQuery where Result: AnyConsoleElementNode {
    func forEach(_ body: (Result) throws -> Void) rethrows {
        try results.forEach(body)
    }

    func print() {
        Swift.print(debugDescription)
    }
}

public extension Inspector.ConsoleQuery where Result: ConsoleElementNode {
    func of<Object: NSObject>(type: Object.Type) -> Inspector.ConsoleQuery<Result> {
        Inspector.ConsoleQuery(
            results.filter { $0.anyElement is Object }
        )
    }
}
