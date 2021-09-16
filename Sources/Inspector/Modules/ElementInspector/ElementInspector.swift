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
        var animationDuration: TimeInterval = CATransaction.animationDuration()
        
        var thumbnailBackgroundStyle: ThumbnailBackgroundStyle = .medium
    }
}

extension ElementInspector {
    struct Appearance {
        let horizontalMargins: CGFloat = 24
        
        let verticalMargins: CGFloat = 12

        var maxViewHierarchyDepthInList = 3
        
        var tintColor = UIColor(hex: 0xBF5AF2)
        
        var accessoryControlBackgroundColor: UIColor { textColor.withAlphaComponent(disabledAlpha / 4) }

        var accessoryControlDisabledBackgroundColor: UIColor { textColor.withAlphaComponent(disabledAlpha / 8) }
        
        var textColor: UIColor = {
            .white
        }()
        
        var secondaryTextColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha * 2)
        }
        
        var tertiaryTextColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha)
        }
        
        var quaternaryTextColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha / 2)
        }
        
        var disabledAlpha: CGFloat = 0.3
        
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
        
        var panelBackgroundColor: UIColor = {
            UIColor(hex: 0x2C2C2E)
        }()
        
        var panelHighlightBackgroundColor: UIColor = {
            UIColor(hex: 0x3A3A3C)
        }()
        
        func titleFont(forRelativeDepth relativeDepth: Int) -> UIFont {
            switch relativeDepth {
            case 0:
                return UIFont.preferredFont(forTextStyle: .title3).bold()

            case 1:
                return UIFont.preferredFont(forTextStyle: .headline).bold()

            case 2:
                return UIFont.preferredFont(forTextStyle: .body).bold()

            case 3:
                return UIFont.preferredFont(forTextStyle: .callout).bold()

            default:
                return UIFont.preferredFont(forTextStyle: .footnote)
            }
        }
    }
}
