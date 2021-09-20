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

enum ThumbnailBackgroundStyle: Int, Swift.CaseIterable {
    case strong, medium, soft

    var color: UIColor {
        switch (self, Inspector.configuration.colorStyle) {
        case (.strong, .dark):
            return UIColor(white: 0.80, alpha: 1)
        case (.medium, .dark):
            return UIColor(white: 0.45, alpha: 1)
        case (.soft, .dark):
            return UIColor(white: 0.10, alpha: 1)

        case (.strong, .light):
            return UIColor(white: 0.40, alpha: 1)
        case (.medium, .light):
            return UIColor(white: 0.80, alpha: 1)
        case (.soft, .light):
            return UIColor(white: 1, alpha: 1)
        }
    }

    var contrastingColor: UIColor {
        switch (self, Inspector.configuration.colorStyle) {
        case (.strong, .dark):
            return .darkText
        case (.medium, .dark):
            return .white
        case (.soft, .dark):
            return .lightGray

        case (.strong, .light):
            return .white
        case (.medium, .light):
            return .darkText
        case (.soft, .light):
            return .darkText
        }
    }

    var image: UIImage {
        switch self {
        case .strong:
            return IconKit.imageOfAppearanceLight()

        case .medium:
            return IconKit.imageOfAppearanceMedium()

        case .soft:
            return IconKit.imageOfAppearanceDark()
        }
    }
}
