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

final class SnapshotStore<Snapshot>: NSObject {
    typealias Provider = Inspector.Provider<Void, Snapshot?>

    var delay: TimeInterval

    let first: Snapshot

    let maxCount: Int

    var latest: Snapshot { snapshots.last ?? first }

    private lazy var snapshots: [Snapshot] = [first]

    private var snapshotProvider: Provider? {
        didSet {
            debounce(#selector(makeSnapshot), delay: delay)
        }
    }

    init(
        _ initial: Snapshot,
        maxCount: Int = Inspector.sharedInstance.configuration.snapshotMaxCount,
        delay: TimeInterval = Inspector.sharedInstance.configuration.snapshotExpirationTimeInterval
    ) {
        first = initial
        self.delay = delay
        self.maxCount = maxCount
    }

    func scheduleSnapshot(_ provider: Provider) {
        snapshotProvider = provider
    }

    @objc private func makeSnapshot() {
        guard let newSnapshot = snapshotProvider?.value else { return }
        snapshots.append(newSnapshot)
        snapshots = Array(snapshots.suffix(maxCount))
    }
}
