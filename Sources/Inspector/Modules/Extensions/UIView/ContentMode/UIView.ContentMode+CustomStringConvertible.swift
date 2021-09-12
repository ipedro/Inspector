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

extension UIView.ContentMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .scaleToFill:
            return "Scale To Fill"
            
        case .scaleAspectFit:
            return "Scale Aspect Fit"
            
        case .scaleAspectFill:
            return "Scale Aspect Fill"
            
        case .redraw:
            return "Redraw"
            
        case .center:
            return "Center"
            
        case .top:
            return "Top"
            
        case .bottom:
            return "Bottom"
            
        case .left:
            return "Left"
            
        case .right:
            return "Right"
            
        case .topLeft:
            return "Top Left"
            
        case .topRight:
            return "Top Right"
            
        case .bottomLeft:
            return "Bottom Left"
            
        case .bottomRight:
            return "Bottom Right"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
