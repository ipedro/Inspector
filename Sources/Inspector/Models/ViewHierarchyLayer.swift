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

import MapKit
import UIKit
import WebKit

typealias ViewHierarchyLayer = Inspector.ViewHierarchyLayer

public extension Inspector {
    struct ViewHierarchyLayer {
        public typealias Filter = (UIView) -> Bool

        // MARK: - Properties

        public var name: String

        var showLabels: Bool = true

        var allowsInternalViews: Bool = false

        var allowsSystemContainers: Bool = false

        public var filter: Filter

        // MARK: - Init

        public static func layer(name: String, filter: @escaping Filter) -> ViewHierarchyLayer {
            ViewHierarchyLayer(name: name, filter: filter)
        }

        // MARK: - Metods

        func makeKeysForInspectableElements(in snapshot: ViewHierarchySnapshot) -> [ViewHierarchyElementKey] {
            filter(viewHierarchy: snapshot.viewHierarchy).compactMap { ViewHierarchyElementKey(reference: $0) }
        }

        func filter(viewHierarchy: [ViewHierarchyElementReference]) -> [ViewHierarchyElementReference] {
            let filteredViews = viewHierarchy.filter {
                guard let rootView = $0.underlyingView else {
                    return false
                }

                if !allowsInternalViews && $0.isInternalView {
                    return false
                }

                if !allowsSystemContainers && $0.isSystemContainer {
                    return false
                }

                let result = filter(rootView)

                return result
            }

            switch allowsInternalViews {
            case true:
                return filteredViews

            case false:
                return filteredViews.filter { $0.isInternalView == false }
            }
        }
    }
}

// MARK: - Built-in layers

public extension ViewHierarchyLayer {
    /// Highlights activity indicator views
    static let activityIndicators = Inspector.ViewHierarchyLayer(name: "Activity indicators", allowsInternalViews: true) { $0 is UIActivityIndicatorView }
    /// Highlights buttons
    static let buttons = Inspector.ViewHierarchyLayer(name: "Buttons", allowsInternalViews: true) { $0 is UIButton }
    /// Highlights collection views
    static let collectionViews = Inspector.ViewHierarchyLayer(name: "Collection views") { $0 is UICollectionView }
    /// Highlights all container views
    static let containerViews = Inspector.ViewHierarchyLayer(name: "Containers", allowsInternalViews: true) { $0.className == "UIView" && $0.children.isEmpty == false }
    /// Highlights all controls
    static let controls = Inspector.ViewHierarchyLayer(name: "Controls", allowsInternalViews: true) { $0 is UIControl || $0.superview is UIControl }
    /// Highlights all image views
    static let images = Inspector.ViewHierarchyLayer(name: "Images", allowsInternalViews: true) { $0 is UIImageView }
    /// Highlights all map views
    static let maps = Inspector.ViewHierarchyLayer(name: "Maps") { $0 is MKMapView || $0.superview is MKMapView }
    /// Highlights all picker views
    static let pickers = Inspector.ViewHierarchyLayer(name: "Pickers") { $0 is UIPickerView }
    /// Highlights all progress indicator views
    static let progressIndicators = Inspector.ViewHierarchyLayer(name: "Progress indicators") { $0 is UIProgressView }
    /// Highlights all scroll views
    static let scrollViews = Inspector.ViewHierarchyLayer(name: "Scroll views") { $0 is UIScrollView }
    /// Highlights all segmented controls
    static let segmentedControls = Inspector.ViewHierarchyLayer(name: "Segmented controls") { $0 is UISegmentedControl || $0.superview is UISegmentedControl }
    /// Highlights all spacer views
    static let spacerViews = Inspector.ViewHierarchyLayer(name: "Spacers") { $0.className == "UIView" && $0.children.isEmpty }
    /// Highlights all stack views
    static let stackViews = Inspector.ViewHierarchyLayer(name: "Stacks", allowsInternalViews: true) { $0 is UIStackView }
    /// Highlights all table view cells
    static let tableViewCells = Inspector.ViewHierarchyLayer(name: "Table cells") { $0 is UITableViewCell }
    /// Highlights all collection resusable views
    static let collectionViewReusableView = Inspector.ViewHierarchyLayer(name: "Collection reusable views") { $0 is UICollectionReusableView }
    /// Highlights all collection view cells
    static let collectionViewCells = Inspector.ViewHierarchyLayer(name: "Collection cells") { $0 is UICollectionViewCell }
    /// Highlights all static texts
    static let staticTexts = Inspector.ViewHierarchyLayer(name: "Labels", allowsInternalViews: true) { $0 is UILabel } //  || $0 is UIKeyInput
    /// Highlights all switches
    static let switches = Inspector.ViewHierarchyLayer(name: "Switches") { $0 is UISwitch || $0.superview is UISwitch }
    /// Highlights all table views
    static let tables = Inspector.ViewHierarchyLayer(name: "Tables") { $0 is UITableView }
    /// Highlights all text fields
    static let textFields = Inspector.ViewHierarchyLayer(name: "Text fields") { $0 is UITextField || $0.superview is UITextField }
    /// Highlights all text views
    static let textViews = Inspector.ViewHierarchyLayer(name: "Text views") { $0 is UITextView || $0.superview is UITextView }
    /// Highlights all text inputs
    static let textInputs = Inspector.ViewHierarchyLayer(name: "Text inputs") { $0 is UIKeyInput || $0.superview is UIKeyInput }
    /// Highlights all web views
    static let webViews = Inspector.ViewHierarchyLayer(name: "Web views") { $0 is WKWebView || $0.superview is WKWebView }
    /// Highlights all views
    static let allViews = Inspector.ViewHierarchyLayer(name: "All views") { $0.controller == nil }
    /// Highlights all system containers
    static let systemContainers = Inspector.ViewHierarchyLayer(name: "System containers", showLabels: true, allowsInternalViews: true, allowsSystemContainers: true) { $0._isSystemContainer }
    /// Highlights views with an accessbility identifier
    static let withIdentifier = Inspector.ViewHierarchyLayer(name: "With Accessibility identifier") { $0.accessibilityIdentifier?.trimmed.isNilOrEmpty == false }
    /// Highlights views without an accessbility identifier
    static let withoutIdentifier = Inspector.ViewHierarchyLayer(name: "Missing Accessibility identifier") { $0.accessibilityIdentifier?.trimmed.isNilOrEmpty == true }
    /// Shows frames of all views
    static let wireframes = Inspector.ViewHierarchyLayer(name: "Wireframes", showLabels: false, allowsInternalViews: true) { _ in true }
    /// Highlights all
    static let internalViews = Inspector.ViewHierarchyLayer(name: "Internal views", showLabels: true, allowsInternalViews: true) { $0._isInternalView }

    static let viewControllers = Inspector.ViewHierarchyLayer(name: "View Controllers", showLabels: true, allowsInternalViews: true, allowsSystemContainers: true) { $0.controller != nil }
}
