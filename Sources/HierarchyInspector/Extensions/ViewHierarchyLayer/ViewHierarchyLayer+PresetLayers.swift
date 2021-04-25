//
//  ViewHierarchyLayer+PresetLayers.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit
import MapKit
import WebKit

// MARK: - Preset Layers

public extension ViewHierarchyLayer {
    /// Shows activity indicator views
    static let activityIndicators         = ViewHierarchyLayer.layer(name: "Activity indicators")        { $0 is UIActivityIndicatorView }
    /// Shows buttons
    static let buttons                    = ViewHierarchyLayer.layer(name: "Buttons")                    { $0 is UIButton }
    /// Shows collection views
    static let collectionViews            = ViewHierarchyLayer.layer(name: "Collection views")           { $0 is UICollectionView }
    /// Shows all container views
    static let containerViews             = ViewHierarchyLayer.layer(name: "Containers")                 { $0.className == "UIView" && $0.originalSubviews.isEmpty == false }
    /// Shows all controls
    static let controls                   = ViewHierarchyLayer.layer(name: "Controls")                   { $0 is UIControl || $0.superview is UIControl }
    /// Shows all image views
    static let images                     = ViewHierarchyLayer.layer(name: "Images")                     { $0 is UIImageView }
    /// Shows all map views
    static let maps                       = ViewHierarchyLayer.layer(name: "Maps")                       { $0 is MKMapView || $0.superview is MKMapView }
    /// Shows all picker views
    static let pickers                    = ViewHierarchyLayer.layer(name: "Pickers")                    { $0 is UIPickerView }
    /// Shows all progress indicator views
    static let progressIndicators         = ViewHierarchyLayer.layer(name: "Progress indicators")        { $0 is UIProgressView }
    /// Shows all scroll views
    static let scrollViews                = ViewHierarchyLayer.layer(name: "Scroll views")               { $0 is UIScrollView }
    /// Shows all segmented controls
    static let segmentedControls          = ViewHierarchyLayer.layer(name: "Segmented controls")         { $0 is UISegmentedControl || $0.superview is UISegmentedControl }
    /// Shows all spacer views
    static let spacerViews                = ViewHierarchyLayer.layer(name: "Spacers")                    { $0.className == "UIView" && $0.originalSubviews.isEmpty }
    /// Shows all stack views
    static let stackViews                 = ViewHierarchyLayer.layer(name: "Stacks")                     { $0 is UIStackView }
    /// Shows all table view cells
    static let tableViewCells             = ViewHierarchyLayer.layer(name: "Table cells")                { $0 is UITableViewCell }
    /// Shows all collection resusable views
    static let collectionViewReusableView = ViewHierarchyLayer.layer(name: "Collection reusable views")  { $0 is UICollectionReusableView }
    /// Shows all collection view cells
    static let collectionViewCells        = ViewHierarchyLayer.layer(name: "Collection cells")           { $0 is UICollectionViewCell }
    /// Shows all static texts
    static let staticTexts                = ViewHierarchyLayer.layer(name: "Labels")                     { $0 is UILabel } //  || $0 is UIKeyInput
    /// Shows all switches
    static let switches                   = ViewHierarchyLayer.layer(name: "Switches")                   { $0 is UISwitch || $0.superview is UISwitch }
    /// Shows all table views
    static let tables                     = ViewHierarchyLayer.layer(name: "Tables")                     { $0 is UITableView }
    /// Shows all text fields
    static let textFields                 = ViewHierarchyLayer.layer(name: "Text fields")                { $0 is UITextField || $0.superview is UITextField }
    /// Shows all text views
    static let textViews                  = ViewHierarchyLayer.layer(name: "Text views")                 { $0 is UITextView || $0.superview is UITextView }
    /// Shows all text inputs
    static let textInputs                 = ViewHierarchyLayer.layer(name: "Text inputs")                { $0 is UIKeyInput || $0.superview is UIKeyInput }
    /// Shows all web views
    static let webViews                   = ViewHierarchyLayer.layer(name: "Web views")                  { $0 is WKWebView || $0.superview is WKWebView }
    
}


// MARK: - Internal Layers

extension ViewHierarchyLayer {
    static let allViews: ViewHierarchyLayer = .layer(name: "All views") { _ in true }
    
    static let wireframes = ViewHierarchyLayer(name: "Wireframes", showLabels: false) { _ in true }
    
    static let internalViews = ViewHierarchyLayer(name: "Internal views", showLabels: true, allowsSystemViews: true) { $0.isSystemView && !$0.isSystemContainerView }
    
    static let systemContainers = ViewHierarchyLayer(name: "System containers", showLabels: true, allowsSystemViews: true) { $0.isSystemContainerView }
    
    static let icons: ViewHierarchyLayer = .layer(name: "Icons") { $0 is Icon }
    
}
