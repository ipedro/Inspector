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

enum InspectorColorStyle {
    case light, dark

    init(with traitCollection: UITraitCollection) {
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .dark:
                self = .dark
            default:
                self = .light
            }
        } else {
            self = .dark
        }
    }

    var textColor: UIColor {
        dynamicColor { colorStyle in
            switch colorStyle {
            case .light:
                return .darkText
            case .dark:
                return .white
            }
        }
    }

    var shadowColor: UIColor {
        dynamicColor { colorStyle in
            switch colorStyle {
            case .dark:
                return .black
            case .light:
                return .init(white: 0, alpha: disabledAlpha * 2)
            }
        }
    }

    var backgroundColor: UIColor {
        dynamicColor { colorStyle in
            switch colorStyle {
            case .dark:
                return UIColor(hex: 0x2C2C2E)
            case .light:
                return UIColor(hex: 0xF5F5F5)
            }
        }
    }

    var highlightBackgroundColor: UIColor {
        dynamicColor { colorStyle in
            switch colorStyle {
            case .dark:
                return UIColor(hex: 0x3A3A3C)
            case .light:
                return .white
            }
        }.withAlphaComponent(0.5)
    }

    var tintColor: UIColor {
        UIColor(hex: 0xBF5AF2)
    }

    var softTintColor: UIColor {
        tintColor.withAlphaComponent(disabledAlpha)
    }

    var blurStyle: UIBlurEffect.Style {
        if #available(iOS 13.0, *) {
            switch self {
            case .dark:
                return .systemMaterial
            case .light:
                return .systemThinMaterial
            }
        } else {
            return .regular
        }
    }

    var selectedSegmentedControlForegroundColor: UIColor {
        dynamicColor { colorStyle in
            switch colorStyle {
            case .dark:
                return textColor
            case .light:
                return backgroundColor
            }
        }
    }

    public var emptyLayerColor: UIColor { wireframeLayerColor }

    public var wireframeLayerColor: UIColor { tertiaryTextColor }

    var cellHighlightBackgroundColor: UIColor {
        dynamicColor { colorStyle in
            switch colorStyle {
            case .light:
                return .white.withAlphaComponent(disabledAlpha)
            case .dark:
                return .white.withAlphaComponent(disabledAlpha / 7)
            }
        }
    }

    var layoutConstraintsCardBackgroundColor: UIColor {
        dynamicColor { colorStyle in
            switch colorStyle {
            case .light:
                return .white.withAlphaComponent(disabledAlpha * 3)
            case .dark:
                return softTintColor
            }
        }
    }

    var layoutConstraintsCardInactiveBackgroundColor: UIColor {
        return accessoryControlBackgroundColor
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

    var disabledAlpha: CGFloat {
        switch self {
        case .dark:
            return 1 / 3
        case .light:
            return 0.2
        }
    }

    private func dynamicColor(_ closure: @escaping (InspectorColorStyle) -> UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                closure(.init(with: traitCollection))
            }
        }

        return closure(self)
    }
}

// MARK: - ColorStylable

protocol ColorStylable {}

extension ColorStylable {
    var colorStyle: InspectorColorStyle { Inspector.sharedInstance.configuration.colorStyle }
}

extension UIView: ColorStylable {}

extension UIViewController: ColorStylable {}
