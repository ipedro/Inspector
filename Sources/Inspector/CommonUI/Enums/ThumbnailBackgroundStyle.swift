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

enum ThumbnailBackgroundStyle: Hashable, CaseIterable, RawRepresentable {
    typealias RawValue = Int

    typealias AllCases = [ThumbnailBackgroundStyle]

    static let allCases: [ThumbnailBackgroundStyle] = [
        strong,
        medium,
        systemBackground
    ]

    case strong
    case medium
    case systemBackground
    case custom(UIColor)

    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .strong
        case 1:
            self = .medium
        case 2:
            self = .systemBackground
        default:
            return nil
        }
    }

    var rawValue: Int {
        switch self {
        case .strong:
            return 0
        case .medium:
            return 1
        case .systemBackground:
            return 2
        case .custom:
            return -1
        }
    }

    var color: UIColor {
        switch (self, Inspector.sharedInstance.configuration.colorStyle) {
        case (.strong, .dark):
            return UIColor(white: 0.40, alpha: 1)
        case (.medium, .dark):
            return UIColor(white: 0.80, alpha: 1)
        case (.systemBackground, .dark):
            return UIColor(white: 0, alpha: 1)

        case (.strong, .light):
            return UIColor(white: 0.40, alpha: 1)
        case (.medium, .light):
            return UIColor(white: 0.80, alpha: 1)
        case (.systemBackground, .light):
            return UIColor(white: 1, alpha: 1)
        case let (.custom(color), _):
            return color
        }
    }

    var contrastingColor: UIColor {
        switch (self, Inspector.sharedInstance.configuration.colorStyle) {
        case (.strong, .dark):
            return .darkText
        case (.medium, .dark):
            return .white
        case (.systemBackground, .dark):
            return .lightGray

        case (.strong, .light):
            return .white
        case (.medium, .light):
            return .darkText
        case (.systemBackground, .light):
            return .darkText

        case let (.custom(color), _):
            return color.contrasting
        }
    }

    var image: UIImage {
        switch self {
        case .strong:
            return IconKit.imageOfAppearanceLight().withRenderingMode(.alwaysTemplate)

        case .custom, .medium:
            return IconKit.imageOfAppearanceMedium().withRenderingMode(.alwaysTemplate)

        case .systemBackground:
            return IconKit.imageOfAppearanceDark().withRenderingMode(.alwaysTemplate)
        }
    }
}
