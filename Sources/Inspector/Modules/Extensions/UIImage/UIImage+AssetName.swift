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

extension UIImage {
    var assetName: String? {
        guard
            let regex = try? NSRegularExpression(pattern: "(?<=named\\().+(?=\\))|(?<=symbol\\()\\w+:\\s\\w+(?=\\))", options: .caseInsensitive),
            let firstMatch = regex.firstMatch(in: description)
        else {
            return nil
        }
        
        let assetName = description.substring(with: firstMatch.range)
        
        return assetName
    }
    
    var sizeDesription: String {
        guard
            let width = formatter.string(from: size.width * scale / screenScale),
            let height = formatter.string(from: size.height * scale / screenScale)
        else {
            return "None"
        }
        
        let sizeDesription = "w: \(width), h: \(height) @\(Int(screenScale))x"
        
        return sizeDesription
    }
}

private extension UIImage {
    static var sharedFormatter = NumberFormatter().then {
        $0.maximumFractionDigits = 1
    }
    
    var formatter: NumberFormatter {
        Self.sharedFormatter
    }
    
    var screenScale: CGFloat {
        UIScreen.main.scale
    }
}
