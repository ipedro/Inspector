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

enum ElementInspector {
    static var configuration = Configuration()

    static var appearance = Appearance()
}

extension ElementInspector {
    struct Configuration {
        var isPresentingFromBottomSheet: Bool {
            #if swift(>=5.5)
            if #available(iOS 15.0, *) {
                return Inspector.host?.window?.traitCollection.userInterfaceIdiom == .phone
            }
            #endif
            return false
        }

        var isPhoneIdiom: Bool {
            guard let userInterfaceIdiom = Inspector.host?.window?.traitCollection.userInterfaceIdiom else {
                // assume true
                return true
            }
            return userInterfaceIdiom == .phone
        }

        var childrenListMaximumInteractiveDepth = 3

        var animationDuration: TimeInterval = CATransaction.animationDuration()

        var thumbnailBackgroundStyle: ThumbnailBackgroundStyle = .medium
    }
}

extension ElementInspector {
    struct Appearance {
        let horizontalMargins: CGFloat = 24

        let verticalMargins: CGFloat = 12

        var directionalInsets: NSDirectionalEdgeInsets {
            NSDirectionalEdgeInsets(
                horizontal: horizontalMargins,
                vertical: verticalMargins
            )
        }

        var panelPreferredCompressedSize: CGSize {
            CGSize(
                width: min(UIScreen.main.bounds.width, 428),
                height: .zero
            )
        }

        func titleFont(forRelativeDepth relativeDepth: Int) -> UIFont {
            var style: UIFont.TextStyle {
                switch relativeDepth {
                case 0:
                    return .title2

                case 1:
                    return .headline

                case 2:
                    return .body

                case 3:
                    return .callout

                default:
                    return .footnote
                }
            }

            return UIFont.preferredFont(forTextStyle: style).bold()
        }
    }
}
