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

final class SnapshotStore<Element: ExpirableProtocol>: NSObject {
    typealias ElementProvider = Inspector.Provider<Void, Element?>

    let first: Element

    var current: Element { history.last ?? first }

    var currentSnapshotIdentifier: UUID { current.identifier }

    var expirationDate: Date { current.expirationDate }

    // MARK: - Computed Properties

    private var elementProvider: ElementProvider? {
        didSet {
            debounce(#selector(makeSnapshot), delay: first.self.delay)
        }
    }

    private lazy var history: [Element] = [first]

    // MARK: - Init

    init(element: Element) {
        self.first = element
    }

    // MARK: - Methods

    func hasChanges(inRelationTo identifier: UUID) -> Bool {
        current.identifier == identifier
    }

    func scheduleSnapshot(_ elementprovider: ElementProvider) {
        elementProvider = elementprovider
    }

    @objc private func makeSnapshot() {
        guard let newSnapshot = elementProvider?.value else { return }

        history.append(newSnapshot)
    }
}
