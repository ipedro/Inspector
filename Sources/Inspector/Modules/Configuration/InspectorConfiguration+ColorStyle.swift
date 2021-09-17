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

public extension InspectorConfiguration {
    enum ColorStyle {
        case light, dark

        var textColor: UIColor {
            switch self {
            case .light:
                return .darkText
            case .dark:
                return .white
            }
        }

        var shadowColor: UIColor {
            switch self {
            case .dark:
                return .black
            case .light:
                return .init(white: 0, alpha: disabledAlpha)
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .dark:
                return UIColor(hex: 0x2C2C2E)
            case .light:
                return UIColor(hex: 0xF5F5F5)
            }
        }

        var highlightBackgroundColor: UIColor {
            switch self {
            case .dark:
                return UIColor(hex: 0x3A3A3C)
            case .light:
                return .white
            }
        }

        var tintColor: UIColor {
            UIColor(hex: 0xBF5AF2)
        }

        var softTintColor: UIColor {
            tintColor.withAlphaComponent(disabledAlpha)
        }

        var blurStyle: UIBlurEffect.Style {
            switch self {
            case .light:
                if #available(iOS 13.0, *) {
                    return .systemChromeMaterial
                }
                else {
                    return .light
                }
            case .dark:
                if #available(iOS 13.0, *) {
                    return .systemChromeMaterialDark
                }
                else {
                    return .dark
                }
            }
        }

        var selectedSegmentedControlForegroundColor: UIColor {
            switch self {
            case .dark:
                return textColor
            case .light:
                return backgroundColor
            }
        }

        var accessoryControlBackgroundColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha / 4)
        }

        var accessoryControlDisabledBackgroundColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha / 8)
        }

        var secondaryTextColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha * 2)
        }

        var tertiaryTextColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha)
        }

        var quaternaryTextColor: UIColor {
            textColor.withAlphaComponent(disabledAlpha / 2)
        }

        var disabledAlpha: CGFloat { 0.3 }
    }

}

extension UIView {
    var colorStyle: InspectorConfiguration.ColorStyle { Inspector.configuration.colorStyle }
}
