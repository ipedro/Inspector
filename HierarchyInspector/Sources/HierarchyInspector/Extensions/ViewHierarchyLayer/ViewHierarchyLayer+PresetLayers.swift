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

import UIKit
import MapKit
import WebKit

// MARK: - Preset Layers

public extension ViewHierarchyLayer {
    /// Shows activity indicator views
    static let activityIndicators         = ViewHierarchyLayer(name: "Activity indicators")        { $0 is UIActivityIndicatorView }
    /// Shows buttons
    static let buttons                    = ViewHierarchyLayer(name: "Buttons")                    { $0 is UIButton }
    /// Shows collection views
    static let collectionViews            = ViewHierarchyLayer(name: "Collection views")           { $0 is UICollectionView }
    /// Shows all container views
    static let containerViews             = ViewHierarchyLayer(name: "Containers")                 { $0.className == "UIView" && $0.originalSubviews.isEmpty == false }
    /// Shows all controls
    static let controls                   = ViewHierarchyLayer(name: "Controls")                   { $0 is UIControl || $0.superview is UIControl }
    /// Shows all image views
    static let images                     = ViewHierarchyLayer(name: "Images")                     { $0 is UIImageView }
    /// Shows all map views
    static let maps                       = ViewHierarchyLayer(name: "Maps")                       { $0 is MKMapView || $0.superview is MKMapView }
    /// Shows all picker views
    static let pickers                    = ViewHierarchyLayer(name: "Pickers")                    { $0 is UIPickerView }
    /// Shows all progress indicator views
    static let progressIndicators         = ViewHierarchyLayer(name: "Progress indicators")        { $0 is UIProgressView }
    /// Shows all scroll views
    static let scrollViews                = ViewHierarchyLayer(name: "Scroll views")               { $0 is UIScrollView }
    /// Shows all segmented controls
    static let segmentedControls          = ViewHierarchyLayer(name: "Segmented controls")         { $0 is UISegmentedControl || $0.superview is UISegmentedControl }
    /// Shows all spacer views
    static let spacerViews                = ViewHierarchyLayer(name: "Spacers")                    { $0.className == "UIView" && $0.originalSubviews.isEmpty }
    /// Shows all stack views
    static let stackViews                 = ViewHierarchyLayer(name: "Stacks")                     { $0 is UIStackView }
    /// Shows all table view cells
    static let tableViewCells             = ViewHierarchyLayer(name: "Table cells")                { $0 is UITableViewCell }
    /// Shows all collection resusable views
    static let collectionViewReusableView = ViewHierarchyLayer(name: "Collection reusable views")  { $0 is UICollectionReusableView }
    /// Shows all collection view cells
    static let collectionViewCells        = ViewHierarchyLayer(name: "Collection cells")           { $0 is UICollectionViewCell }
    /// Shows all static texts
    static let staticTexts                = ViewHierarchyLayer(name: "Labels")                     { $0 is UILabel } //  || $0 is UIKeyInput
    /// Shows all switches
    static let switches                   = ViewHierarchyLayer(name: "Switches")                   { $0 is UISwitch || $0.superview is UISwitch }
    /// Shows all table views
    static let tables                     = ViewHierarchyLayer(name: "Tables")                     { $0 is UITableView }
    /// Shows all text fields
    static let textFields                 = ViewHierarchyLayer(name: "Text fields")                { $0 is UITextField || $0.superview is UITextField }
    /// Shows all text views
    static let textViews                  = ViewHierarchyLayer(name: "Text views")                 { $0 is UITextView || $0.superview is UITextView }
    /// Shows all text inputs
    static let textInputs                 = ViewHierarchyLayer(name: "Text inputs")                { $0 is UIKeyInput || $0.superview is UIKeyInput }
    /// Shows all web views
    static let webViews                   = ViewHierarchyLayer(name: "Web views")                  { $0 is WKWebView || $0.superview is WKWebView }
    
}


// MARK: - Internal Layers

extension ViewHierarchyLayer {
    static let allViews: ViewHierarchyLayer = ViewHierarchyLayer(name: "All views") { _ in true }
    
    static let wireframes = ViewHierarchyLayer(name: "Wireframes", showLabels: false) { _ in true }
    
    static let internalViews = ViewHierarchyLayer(name: "Internal views", showLabels: true, allowsSystemViews: true) { $0.isSystemView && !$0.isSystemContainerView }
    
    static let systemContainers = ViewHierarchyLayer(name: "System containers", showLabels: true, allowsSystemViews: true) { $0.isSystemContainerView }
    
    static let icons: ViewHierarchyLayer = ViewHierarchyLayer(name: "Icons") { $0 is Icon }
    
}
