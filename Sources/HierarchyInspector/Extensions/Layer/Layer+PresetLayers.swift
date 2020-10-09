//
//  Layer+PresetLayers.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit
import MapKit
import WebKit

// MARK: - Preset Layers

#warning("TODO: add documentation")
public extension ViewHierarchyLayer {
    
    static let allViews           : ViewHierarchyLayer = .layer(name: "All views")            { _ in true }
    static let activityIndicators : ViewHierarchyLayer = .layer(name: "Activity indicators")  { $0 is UIActivityIndicatorView }
    static let buttons            : ViewHierarchyLayer = .layer(name: "Buttons")              { $0 is UIButton }
    static let collectionViews    : ViewHierarchyLayer = .layer(name: "Collection views")     { $0 is UICollectionView }
    static let containerViews     : ViewHierarchyLayer = .layer(name: "Containers")           { $0.className == "UIView" && $0.originalSubviews.isEmpty == false }
    static let controls           : ViewHierarchyLayer = .layer(name: "Controls")             { $0 is UIControl || $0.superview is UIControl }
    static let images             : ViewHierarchyLayer = .layer(name: "Images")               { $0 is UIImageView }
    static let maps               : ViewHierarchyLayer = .layer(name: "Maps")                 { $0 is MKMapView || $0.superview is MKMapView }
    static let pickers            : ViewHierarchyLayer = .layer(name: "Pickers")              { $0 is UIPickerView }
    static let progressIndicators : ViewHierarchyLayer = .layer(name: "Progress indicators")  { $0 is UIProgressView }
    static let scrollViews        : ViewHierarchyLayer = .layer(name: "Scroll views")         { $0 is UIScrollView }
    static let segmentedControls  : ViewHierarchyLayer = .layer(name: "Segmented controls")   { $0 is UISegmentedControl || $0.superview is UISegmentedControl }
    static let spacerViews        : ViewHierarchyLayer = .layer(name: "Spacers")              { $0.className == "UIView" && $0.originalSubviews.isEmpty }
    static let stackViews         : ViewHierarchyLayer = .layer(name: "Stacks")               { $0 is UIStackView }
    static let staticTexts        : ViewHierarchyLayer = .layer(name: "Labels")               { $0 is UILabel } //  || $0 is UIKeyInput
    static let switches           : ViewHierarchyLayer = .layer(name: "Switches")             { $0 is UISwitch || $0.superview is UISwitch }
    static let tables             : ViewHierarchyLayer = .layer(name: "Tables")               { $0 is UITableView }
    static let textFields         : ViewHierarchyLayer = .layer(name: "Text fields")          { $0 is UITextField || $0.superview is UITextField }
    static let textViews          : ViewHierarchyLayer = .layer(name: "Text views")           { $0 is UITextView || $0.superview is UITextView }
    static let textInputs         : ViewHierarchyLayer = .layer(name: "Text inputs")          { $0 is UIKeyInput || $0.superview is UIKeyInput }
    static let webViews           : ViewHierarchyLayer = .layer(name: "Web views")            { $0 is WKWebView || $0.superview is WKWebView }
    
}
