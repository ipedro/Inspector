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

extension UIModalPresentationStyle: CustomStringConvertible {
    var description: String {
        switch self {
        case .fullScreen:
            return "Full Screen"
        case .pageSheet:
            return "Page Sheet"
        case .formSheet:
            return "Form Sheet"
        case .currentContext:
            return "Current Context"
        case .custom:
            return "Custom"
        case .overFullScreen:
            return "Over Full Screen"
        case .overCurrentContext:
            return "Over Current Context"
        case .popover:
            return "Popover"
        case .none:
            return "None"
        case .automatic:
            return "Automatic"
        @unknown default:
            return "Unknown"
        }
    }
}
