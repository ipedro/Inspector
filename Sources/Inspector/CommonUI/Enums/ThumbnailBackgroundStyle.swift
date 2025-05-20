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
            0
        case .medium:
            1
        case .systemBackground:
            2
        case .custom:
            -1
        }
    }

    var color: UIColor {
        switch (self, Inspector.sharedInstance.configuration.colorStyle) {
        case (.strong, .dark):
            UIColor(white: 0.40, alpha: 1)
        case (.medium, .dark):
            UIColor(white: 0.80, alpha: 1)
        case (.systemBackground, .dark):
            UIColor(white: 0, alpha: 1)
        case (.strong, .light):
            UIColor(white: 0.40, alpha: 1)
        case (.medium, .light):
            UIColor(white: 0.80, alpha: 1)
        case (.systemBackground, .light):
            UIColor(white: 1, alpha: 1)
        case let (.custom(color), _):
            color
        }
    }

    var contrastingColor: UIColor {
        switch (self, Inspector.sharedInstance.configuration.colorStyle) {
        case (.strong, .dark):
            .darkText
        case (.medium, .dark):
            .white
        case (.systemBackground, .dark):
            .lightGray
        case (.strong, .light):
            .white
        case (.medium, .light):
            .darkText
        case (.systemBackground, .light):
            .darkText
        case let (.custom(color), _):
            color.contrasting
        }
    }

    var image: UIImage {
        switch self {
        case .strong:
            IconKit.imageOfAppearanceLight().withRenderingMode(.alwaysTemplate)

        case .custom, .medium:
            IconKit.imageOfAppearanceMedium().withRenderingMode(.alwaysTemplate)

        case .systemBackground:
            IconKit.imageOfAppearanceDark().withRenderingMode(.alwaysTemplate)
        }
    }
}
