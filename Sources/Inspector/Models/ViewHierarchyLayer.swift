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

        public var filter: Filter

        // MARK: - Init

        public static func layer(name: String, filter: @escaping Filter) -> ViewHierarchyLayer {
            ViewHierarchyLayer(name: name, filter: filter)
        }

        // MARK: - Metods

        func makeKeysForInspectableElements(in snapshot: ViewHierarchySnapshot) -> [ViewHierarchyElementKey] {
            filter(flattenedViewHierarchy: snapshot.viewHierarchy).map { ViewHierarchyElementKey(reference: $0) }
        }

        func filter(flattenedViewHierarchy: [ViewHierarchyElementReference]) -> [ViewHierarchyElementReference] {
            let filteredViews = flattenedViewHierarchy.filter {
                guard let rootView = $0.underlyingView else { return false }
                return filter(rootView)
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
    static let activityIndicators = ViewHierarchyLayer.layer(name: "Activity indicators") { $0 is UIActivityIndicatorView }
    /// Highlights buttons
    static let buttons = ViewHierarchyLayer.layer(name: "Buttons") { $0 is UIButton }
    /// Highlights collection views
    static let collectionViews = ViewHierarchyLayer.layer(name: "Collection views") { $0 is UICollectionView }
    /// Highlights all container views
    static let containerViews = ViewHierarchyLayer.layer(name: "Containers") { $0.className == "UIView" && $0.children.isEmpty == false }
    /// Highlights all controls
    static let controls = ViewHierarchyLayer.layer(name: "Controls") { $0 is UIControl || $0.superview is UIControl }
    /// Highlights all image views
    static let images = ViewHierarchyLayer.layer(name: "Images") { $0 is UIImageView }
    /// Highlights all map views
    static let maps = ViewHierarchyLayer.layer(name: "Maps") { $0 is MKMapView || $0.superview is MKMapView }
    /// Highlights all picker views
    static let pickers = ViewHierarchyLayer.layer(name: "Pickers") { $0 is UIPickerView }
    /// Highlights all progress indicator views
    static let progressIndicators = ViewHierarchyLayer.layer(name: "Progress indicators") { $0 is UIProgressView }
    /// Highlights all scroll views
    static let scrollViews = ViewHierarchyLayer.layer(name: "Scroll views") { $0 is UIScrollView }
    /// Highlights all segmented controls
    static let segmentedControls = ViewHierarchyLayer.layer(name: "Segmented controls") { $0 is UISegmentedControl || $0.superview is UISegmentedControl }
    /// Highlights all spacer views
    static let spacerViews = ViewHierarchyLayer.layer(name: "Spacers") { $0.className == "UIView" && $0.children.isEmpty }
    /// Highlights all stack views
    static let stackViews = ViewHierarchyLayer.layer(name: "Stacks") { $0 is UIStackView }
    /// Highlights all table view cells
    static let tableViewCells = ViewHierarchyLayer.layer(name: "Table cells") { $0 is UITableViewCell }
    /// Highlights all collection resusable views
    static let collectionViewReusableView = ViewHierarchyLayer.layer(name: "Collection reusable views") { $0 is UICollectionReusableView }
    /// Highlights all collection view cells
    static let collectionViewCells = ViewHierarchyLayer.layer(name: "Collection cells") { $0 is UICollectionViewCell }
    /// Highlights all static texts
    static let staticTexts = ViewHierarchyLayer.layer(name: "Labels") { $0 is UILabel } //  || $0 is UIKeyInput
    /// Highlights all switches
    static let switches = ViewHierarchyLayer.layer(name: "Switches") { $0 is UISwitch || $0.superview is UISwitch }
    /// Highlights all table views
    static let tables = ViewHierarchyLayer.layer(name: "Tables") { $0 is UITableView }
    /// Highlights all text fields
    static let textFields = ViewHierarchyLayer.layer(name: "Text fields") { $0 is UITextField || $0.superview is UITextField }
    /// Highlights all text views
    static let textViews = ViewHierarchyLayer.layer(name: "Text views") { $0 is UITextView || $0.superview is UITextView }
    /// Highlights all text inputs
    static let textInputs = ViewHierarchyLayer.layer(name: "Text inputs") { $0 is UIKeyInput || $0.superview is UIKeyInput }
    /// Highlights all web views
    static let webViews = ViewHierarchyLayer.layer(name: "Web views") { $0 is WKWebView || $0.superview is WKWebView }
    /// Highlights all views
    static let allViews = ViewHierarchyLayer.layer(name: "All views") { _ in true }
    /// Highlights all system containers
    static let systemContainers = Inspector.ViewHierarchyLayer(name: "System containers", showLabels: true, allowsInternalViews: true) { $0._isSystemContainer }
    /// Highlights views with an accessbility identifier
    static let withIdentifier = ViewHierarchyLayer.layer(name: "With identifier") { $0.accessibilityIdentifier?.trimmed.isNilOrEmpty == false }
    /// Highlights views without an accessbility identifier
    static let withoutIdentifier = ViewHierarchyLayer.layer(name: "Without identifier") { $0.accessibilityIdentifier?.trimmed.isNilOrEmpty == true }
    /// Shows frames of all views
    static let wireframes = Inspector.ViewHierarchyLayer(name: "Wireframes", showLabels: false, allowsInternalViews: true) { _ in true }
    /// Highlights all
    static let internalViews = Inspector.ViewHierarchyLayer(name: "Internal views", showLabels: true, allowsInternalViews: true) { $0._isInternalView && !$0._isSystemContainer }

     static let viewControllers = Inspector.ViewHierarchyLayer(name: "View Controllers", showLabels: true, allowsInternalViews: true) { $0._layerView?.element as? ViewHierarchyController != nil }
}
