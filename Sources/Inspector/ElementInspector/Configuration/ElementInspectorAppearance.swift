//  Copyright (c) 2022 Pedro Almeida
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

struct ElementInspectorAppearance: Hashable {
    let horizontalMargins: CGFloat = 24

    let verticalMargins: CGFloat = 12

    let elementInspectorCornerRadius: CGFloat = 30

    var panelInitialTransform: CGAffineTransform {
        CGAffineTransform(
            scaleX: 0.99,
            y: 0.98
        ).translatedBy(
            x: .zero,
            y: -verticalMargins
        )
    }

    var directionalInsets: NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(
            horizontal: horizontalMargins,
            vertical: verticalMargins
        )
    }

    func font(forRelativeDepth relativeDepth: Int) -> UIFont {
        UIFont.preferredFont(
            forTextStyle: {
                switch relativeDepth {
                case let depth where depth <= -5:
                    return .title2
                case -4:
                    return .headline
                case -3:
                    return .subheadline
                case -2:
                    return .body
                case -1:
                    return .callout
                default:
                    return .footnote
                }
            }()
        )
    }

    func titleFont(forRelativeDepth relativeDepth: Int) -> UIFont {
        font(forRelativeDepth: relativeDepth - 5).bold()
    }
}
