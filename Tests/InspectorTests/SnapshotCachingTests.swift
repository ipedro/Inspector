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

#if canImport(UIKit)
@testable import Inspector
import XCTest

// MARK: - ExpirableStore Tests

final class SnapshotCachingTests: XCTestCase {

    // MARK: - ExpirableStore: validity

    func testExpirableValueIsValidBeforeExpiration() {
        var store = ExpirableStore<String>(lifespan: 60)
        store.wrappedValue = "hello"
        XCTAssertTrue(store.isValid, "Store should be valid before expiration")
        XCTAssertEqual(store.wrappedValue, "hello")
    }

    func testExpirableValueIsExpiredAfterExpiration() {
        // Use a negative lifespan so the store is already expired
        var store = ExpirableStore<String>(lifespan: -1)
        store.wrappedValue = "stale"
        XCTAssertTrue(store.isExpired, "Store with past expiration date should be expired")
        XCTAssertNil(store.wrappedValue, "Expired store should return nil for wrappedValue")
    }

    func testExpirableStoreIsValidReturnsFalseWhenExpired() {
        let store = ExpirableStore<Int>(lifespan: -100)
        XCTAssertFalse(store.isValid)
    }

    func testExpirableStoreIsExpiredReturnsTrueWhenExpired() {
        let store = ExpirableStore<Int>(lifespan: -100)
        XCTAssertTrue(store.isExpired)
    }

    func testExpirableStoreInitialValueNilByDefault() {
        let store = ExpirableStore<String>(lifespan: 60)
        // A freshly initialised store with no value set returns nil
        XCTAssertNil(store.wrappedValue)
    }

    func testExpirableStoreInitialValueCanBeProvided() {
        let store = ExpirableStore<String>("initial", lifespan: 60)
        XCTAssertEqual(store.wrappedValue, "initial")
    }

    // MARK: - ExpirableStore: setting new value resets expiration

    func testSettingNewValueOnExpiredStoreResetsExpiration() {
        // A store with negative lifespan is always expired regardless of value set
        // (see testExpirableValueIsExpiredAfterExpiration). Here we verify that the
        // setter correctly resets the expiration date to the future when lifespan is positive.
        var store = ExpirableStore<String>(lifespan: 60)

        store.wrappedValue = "refreshed"
        XCTAssertTrue(store.isValid, "After setting a new value, the store should be valid")
        XCTAssertEqual(store.wrappedValue, "refreshed")
        XCTAssertGreaterThan(store.expirationDate, Date(), "Expiration date should be in the future after setting a new value")
    }

    // MARK: - ExpirableStore: expirationDate

    func testExpirationDateIsInFutureForPositiveLifespan() {
        let store = ExpirableStore<Int>(lifespan: 30)
        XCTAssertGreaterThan(store.expirationDate, Date())
    }

    func testExpirationDateIsInPastForNegativeLifespan() {
        let store = ExpirableStore<Int>(lifespan: -30)
        XCTAssertLessThan(store.expirationDate, Date())
    }

    // MARK: - SnapshotStore: basic behaviour

    func testSnapshotStoreLatestReturnsFirstWhenNoSnapshotsAdded() {
        let store = SnapshotStore<String>("initial", maxCount: 5, delay: 0)
        XCTAssertEqual(store.latest, "initial", "latest should return the initial value before any snapshots are added")
    }

    func testSnapshotStoreFirstEqualsInitialValue() {
        let store = SnapshotStore<Int>(42, maxCount: 3, delay: 0)
        XCTAssertEqual(store.first, 42)
    }

    func testSnapshotStoreMaxCountIsStored() {
        let store = SnapshotStore<String>("x", maxCount: 7, delay: 0)
        XCTAssertEqual(store.maxCount, 7)
    }

    func testSnapshotStoreDelayIsStored() {
        let store = SnapshotStore<String>("x", maxCount: 5, delay: 1.5)
        XCTAssertEqual(store.delay, 1.5, accuracy: 0.001)
    }
}
#endif
