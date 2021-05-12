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

import Foundation

enum Texts {
    
    static func inspect(_ name: Any) -> String {
        "Inspect \(String(describing: name))..."
    }
    
    static func inspectableViews(_ viewCount: Int, in className: String) -> String {
        switch viewCount {
        case 1:
            return "\(viewCount) inspectable view in \(className)"
            
        default:
            return "\(viewCount) inspectable views in \(className)"
        }
    }
    
    static func allResults(count: Int, in elementName: String) -> String {
        switch count {
        case 1:
            return "\(count) Search result in \(elementName)"
            
        default:
            return "\(count) Search results in \(elementName)"
        }
    }
    
    static func emptyLayer(with description: String) -> String {
        "No \(description) found"
    }
    
    static let highlightLayers = "Highlight Layers"
    
    static let hideAllLayers = "Hide all layers"
    
    static let hierarchySearch = "Hierarchy Search"
    
    static let presentInspector = "Open Inspector..."
    
    static let showAllLayers = "Show all layers"
    
    static let dismissView = "Dismiss View"
}
