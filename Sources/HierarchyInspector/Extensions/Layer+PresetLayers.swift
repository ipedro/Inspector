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
extension HierarchyInspector.Layer {
    
    public static let allViews           = HierarchyInspector.Layer(name: "All views")            { _ in true }
    public static let activityIndicators = HierarchyInspector.Layer(name: "Activity indicators")  { $0 is UIActivityIndicatorView }
    public static let buttons            = HierarchyInspector.Layer(name: "Buttons")              { $0 is UIButton }
    public static let collectionViews    = HierarchyInspector.Layer(name: "Collection views")     { $0 is UICollectionView }
    public static let containerViews     = HierarchyInspector.Layer(name: "Containers")           { $0.className == "UIView" && $0.originalSubviews.isEmpty == false }
    public static let controls           = HierarchyInspector.Layer(name: "Controls")             { $0 is UIControl || $0.superview is UIControl }
    public static let images             = HierarchyInspector.Layer(name: "Images")               { $0 is UIImageView }
    public static let maps               = HierarchyInspector.Layer(name: "Maps")                 { $0 is MKMapView || $0.superview is MKMapView }
    public static let pickers            = HierarchyInspector.Layer(name: "Pickers")              { $0 is UIPickerView }
    public static let progressIndicators = HierarchyInspector.Layer(name: "Progress indicators")  { $0 is UIProgressView }
    public static let scrollViews        = HierarchyInspector.Layer(name: "Scroll views")         { $0 is UIScrollView }
    public static let segmentedControls  = HierarchyInspector.Layer(name: "Segmented controls")   { $0 is UISegmentedControl || $0.superview is UISegmentedControl }
    public static let spacerViews        = HierarchyInspector.Layer(name: "Spacers")              { $0.className == "UIView" && $0.originalSubviews.isEmpty }
    public static let stackViews         = HierarchyInspector.Layer(name: "Stacks")               { $0 is UIStackView }
    public static let staticTexts        = HierarchyInspector.Layer(name: "Labels")               { $0 is UILabel } //  || $0 is UIKeyInput
    public static let switches           = HierarchyInspector.Layer(name: "Switches")             { $0 is UISwitch || $0.superview is UISwitch }
    public static let tables             = HierarchyInspector.Layer(name: "Tables")               { $0 is UITableView }
    public static let textFields         = HierarchyInspector.Layer(name: "Text fields")          { $0 is UITextField || $0.superview is UITextField }
    public static let textViews          = HierarchyInspector.Layer(name: "Text views")           { $0 is UITextView || $0.superview is UITextView }
    public static let textInputs         = HierarchyInspector.Layer(name: "Text inputs")          { $0 is UIKeyInput || $0.superview is UIKeyInput }
    public static let webViews           = HierarchyInspector.Layer(name: "Web views")            { $0 is WKWebView || $0.superview is WKWebView }
    
}
