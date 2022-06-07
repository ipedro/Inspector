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

/// An array of element inspector sections.
public typealias InspectorElementSections = [InspectorElementSection]

/// An object that represents an inspector section.
public struct InspectorElementSection {
    public var title: String?
    public private(set) var dataSources: [InspectorElementSectionDataSource]

    public init(title: String? = nil, rows: [InspectorElementSectionDataSource] = []) {
        self.title = title
        self.dataSources = rows
    }

    public init(title: String? = nil, rows: InspectorElementSectionDataSource...) {
        self.title = title
        self.dataSources = rows
    }

    public init(title: String? = nil, rows: [InspectorElementSectionDataSource?]) {
        self.title = title
        self.dataSources = rows.compactMap { $0 }
    }

    public init(title: String? = nil, rows: InspectorElementSectionDataSource?...) {
        self.title = title
        self.dataSources = rows.compactMap { $0 }
    }

    public mutating func append(_ dataSource: InspectorElementSectionDataSource?) {
        guard let dataSource = dataSource else {
            return
        }

        dataSources.append(dataSource)
    }
}

// MARK: - Array Extensions

public extension InspectorElementSections {
    static let empty = InspectorElementSections()
    
    init(with dataSources: InspectorElementSectionDataSource?...) {
        let rows = dataSources.compactMap({ $0 })

        self = [InspectorElementSection(rows: rows)]
    }
}
