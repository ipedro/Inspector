//
//  CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import Foundation

/// A type that provides a collection of all of its values.
///
/// Replica with internal access level of [CustomStringConvertible](https://developer.apple.com/documentation/swift/caseiterable).
///
/// Types that conform to the `CaseIterable` protocol are typically
/// enumerations without associated values. When using a `CaseIterable` type,
/// you can access a collection of all of the type's cases by using the type's
/// `allCases` property.
///
/// For example, the `CompassDirection` enumeration declared in this example
/// conforms to `CaseIterable`. You access the number of cases and the cases
/// themselves through `CompassDirection.allCases`.
///
///     enum CompassDirection: CaseIterable {
///         case north, south, east, west
///     }
///
///     print("There are \(CompassDirection.allCases.count) directions.")
///     // Prints "There are 4 directions."
///     let caseList = CompassDirection.allCases
///                                    .map({ "\($0)" })
///                                    .joined(separator: ", ")
///     // caseList == "north, south, east, west"
///
/// Conforming to the CaseIterable Protocol
/// =======================================
///
/// The compiler can automatically provide an implementation of the
/// `CaseIterable` requirements for any enumeration without associated values
/// or `@available` attributes on its cases. The synthesized `allCases`
/// collection provides the cases in order of their declaration.
///
/// You can take advantage of this compiler support when defining your own
/// custom enumeration by declaring conformance to `CaseIterable` in the
/// enumeration's original declaration. The `CompassDirection` example above
/// demonstrates this automatic implementation.
protocol CaseIterable {

    /// A type that can represent a collection of all values of this type.
    associatedtype AllCases : Collection where Self == Self.AllCases.Element

    /// A collection of all values of this type.
    static var allCases: Self.AllCases { get }
}
