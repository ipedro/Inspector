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

extension UIKeyboardType: CustomStringConvertible {
    var description: String {
        switch self {
        case .default:
            return Texts.default

        case .asciiCapable:
            return "Ascii Capable"

        case .numbersAndPunctuation:
            return "Numbers And Punctuation"

        case .URL:
            return "URL"

        case .numberPad:
            return "Number Pad"

        case .phonePad:
            return "Phone Pad"

        case .namePhonePad:
            return "Name Phone Pad"

        case .emailAddress:
            return "Email Address"

        case .decimalPad:
            return "Decimal Pad"

        case .twitter:
            return "Twitter"

        case .webSearch:
            return "Web Search"

        case .asciiCapableNumberPad:
            return "Ascii Capable Number Pad"

        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
