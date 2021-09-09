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

extension UIActivityIndicatorView.Style: CustomStringConvertible {
    
    #if swift(>=5.0)
    var description: String {
        switch self {
        case .medium:
            return "Medium"
        
        case .large:
            return "Large"
        
        case .whiteLarge:
            return "White Large (deprecated)"
        
        case .white:
            return "White (deprecated)"
        
        case .gray:
            return "Gray (deprecated)"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    #else
    var description: String {
        switch self {
        case .whiteLarge:
            return "White Large"
        
        case .white:
            return "White"
        
        case .gray:
            return "Gray"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    #endif
    
}
