//
//  Layer+PresetLayers.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit
import MapKit
import WebKit

// MARK: - Preset Layers

// TODO: add documentation
public extension HierarchyInspector.Layer {
    
    static let allViews           : HierarchyInspector.Layer = .layer(name: "All views")            { _ in true }
    static let activityIndicators : HierarchyInspector.Layer = .layer(name: "Activity indicators")  { $0 is UIActivityIndicatorView }
    static let buttons            : HierarchyInspector.Layer = .layer(name: "Buttons")              { $0 is UIButton }
    static let collectionViews    : HierarchyInspector.Layer = .layer(name: "Collection views")     { $0 is UICollectionView }
    static let containerViews     : HierarchyInspector.Layer = .layer(name: "Containers")           { $0.className == "UIView" && $0.originalSubviews.isEmpty == false }
    static let controls           : HierarchyInspector.Layer = .layer(name: "Controls")             { $0 is UIControl || $0.superview is UIControl }
    static let images             : HierarchyInspector.Layer = .layer(name: "Images")               { $0 is UIImageView }
    static let maps               : HierarchyInspector.Layer = .layer(name: "Maps")                 { $0 is MKMapView || $0.superview is MKMapView }
    static let pickers            : HierarchyInspector.Layer = .layer(name: "Pickers")              { $0 is UIPickerView }
    static let progressIndicators : HierarchyInspector.Layer = .layer(name: "Progress indicators")  { $0 is UIProgressView }
    static let scrollViews        : HierarchyInspector.Layer = .layer(name: "Scroll views")         { $0 is UIScrollView }
    static let segmentedControls  : HierarchyInspector.Layer = .layer(name: "Segmented controls")   { $0 is UISegmentedControl || $0.superview is UISegmentedControl }
    static let spacerViews        : HierarchyInspector.Layer = .layer(name: "Spacers")              { $0.className == "UIView" && $0.originalSubviews.isEmpty }
    static let stackViews         : HierarchyInspector.Layer = .layer(name: "Stacks")               { $0 is UIStackView }
    static let staticTexts        : HierarchyInspector.Layer = .layer(name: "Labels")               { $0 is UILabel } //  || $0 is UIKeyInput
    static let switches           : HierarchyInspector.Layer = .layer(name: "Switches")             { $0 is UISwitch || $0.superview is UISwitch }
    static let tables             : HierarchyInspector.Layer = .layer(name: "Tables")               { $0 is UITableView }
    static let textFields         : HierarchyInspector.Layer = .layer(name: "Text fields")          { $0 is UITextField || $0.superview is UITextField }
    static let textViews          : HierarchyInspector.Layer = .layer(name: "Text views")           { $0 is UITextView || $0.superview is UITextView }
    static let textInputs         : HierarchyInspector.Layer = .layer(name: "Text inputs")          { $0 is UIKeyInput || $0.superview is UIKeyInput }
    static let webViews           : HierarchyInspector.Layer = .layer(name: "Web views")            { $0 is WKWebView || $0.superview is WKWebView }
    
}
