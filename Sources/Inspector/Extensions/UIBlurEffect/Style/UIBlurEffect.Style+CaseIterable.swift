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

@available(iOS 13.0, *)
extension UIBlurEffect.Style: CustomStringConvertible {
    var description: String {
        switch self {
        case .extraLight:
            return "Extra Light"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .regular:
            return "Regular"
        case .prominent:
            return "Prominent"
        case .systemUltraThinMaterial:
            return "Ultra Thin Material"
        case .systemThinMaterial:
            return "Thin Material"
        case .systemMaterial:
            return "Material"
        case .systemThickMaterial:
            return "Thick Material"
        case .systemChromeMaterial:
            return "Chrome Material"
        case .systemUltraThinMaterialLight:
            return "Ultra Thin Material Light"
        case .systemThinMaterialLight:
            return "Thin Material Light"
        case .systemMaterialLight:
            return "Material Light"
        case .systemThickMaterialLight:
            return "Thick Material Light"
        case .systemChromeMaterialLight:
            return "Chrome Material Light"
        case .systemUltraThinMaterialDark:
            return "Ultra Thin Material Dark"
        case .systemThinMaterialDark:
            return "Thin Material Dark"
        case .systemMaterialDark:
            return "Material Dark"
        case .systemThickMaterialDark:
            return "Thick Material Dark"
        case .systemChromeMaterialDark:
            return "Chrome Material Dark"
        @unknown default:
            return "Unkown"
        }
    }
}
