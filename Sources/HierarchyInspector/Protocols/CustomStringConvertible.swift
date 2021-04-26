import Foundation

/// A type with a customized textual representation.
///
/// Replica with internal access level of [CustomStringConvertible](https://developer.apple.com/documentation/swift/customstringconvertible).
///
/// Types that conform to the `CustomStringConvertible` protocol can provide
/// their own representation to be used when converting an instance to a
/// string. The `String(describing:)` initializer is the preferred way to
/// convert an instance of *any* type to a string. If the passed instance
/// conforms to `CustomStringConvertible`, the `String(describing:)`
/// initializer and the `print(_:)` function use the instance's custom
/// `description` property.
///
/// Accessing a type's `description` property directly or using
/// `CustomStringConvertible` as a generic constraint is discouraged.
///
/// Conforming to the CustomStringConvertible Protocol
/// ==================================================
///
/// Add `CustomStringConvertible` conformance to your custom types by defining
/// a `description` property.
///
/// For example, this custom `Point` struct uses the default representation
/// supplied by the standard library:
///
///     struct Point {
///         let x: Int, y: Int
///     }
///
///     let p = Point(x: 21, y: 30)
///     print(p)
///     // Prints "Point(x: 21, y: 30)"
///
/// After implementing the `description` property and declaring
/// `CustomStringConvertible` conformance, the `Point` type provides its own
/// custom representation.
///
///     extension Point: CustomStringConvertible {
///         var description: String {
///             return "(\(x), \(y))"
///         }
///     }
///
///     print(p)
///     // Prints "(21, 30)"
protocol CustomStringConvertible {

    /// A textual representation of this instance.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(describing:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `description` property for types that conform to
    /// `CustomStringConvertible`:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    var description: String { get }
}

extension String: CustomStringConvertible {}
