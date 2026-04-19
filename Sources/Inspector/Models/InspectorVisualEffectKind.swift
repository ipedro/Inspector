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

internal enum InspectorVisualEffectKind: CaseIterable, Equatable, CustomStringConvertible {
    case none
    case blur(UIBlurEffect.Style)
    case glassRegular
    case glassClear
    case glassContainer

    static var allCases: [InspectorVisualEffectKind] {
        var cases: [InspectorVisualEffectKind] = [.none]
        cases.append(contentsOf: UIBlurEffect.Style.allCases.map(Self.blur))
        if #available(iOS 26.0, *) {
            cases.append(contentsOf: [.glassRegular, .glassClear, .glassContainer])
        }
        return cases
    }

    static var appearanceCases: [InspectorVisualEffectKind] {
        var cases: [InspectorVisualEffectKind] = [.none]
        cases.append(contentsOf: UIBlurEffect.Style.allCases.map(Self.blur))
        if #available(iOS 26.0, *) {
            cases.append(contentsOf: [.glassRegular, .glassClear])
        }
        return cases
    }

    static func current(for effect: UIVisualEffect?) -> InspectorVisualEffectKind? {
        guard let effect else { return .none }
        if let blur = effect as? UIBlurEffect, let style = blur.style {
            return .blur(style)
        }
        if #available(iOS 26.0, *) {
            if let glass = effect as? UIGlassEffect {
                return glass.resolvedStyle == .clear ? .glassClear : .glassRegular
            }
            if effect is UIGlassContainerEffect {
                return .glassContainer
            }
        }
        return nil
    }

    func makeEffect() -> UIVisualEffect? {
        switch self {
        case .none:
            return nil
        case let .blur(style):
            return UIBlurEffect(style: style)
        case .glassRegular:
            if #available(iOS 26.0, *) {
                return UIGlassEffect(style: .regular)
            }
            return nil
        case .glassClear:
            if #available(iOS 26.0, *) {
                return UIGlassEffect(style: .clear)
            }
            return nil
        case .glassContainer:
            if #available(iOS 26.0, *) {
                return UIGlassContainerEffect()
            }
            return nil
        }
    }

    var description: String {
        switch self {
        case .none:
            return "None"
        case let .blur(style):
            return "Blur: \(style.description)"
        case .glassRegular:
            return "Glass: Regular"
        case .glassClear:
            return "Glass: Clear"
        case .glassContainer:
            return "Glass Container"
        }
    }
}

@available(iOS 26.0, *)
extension UIGlassEffect.Style: CaseIterable {
    public static var allCases: [UIGlassEffect.Style] { [.regular, .clear] }
}

@available(iOS 26.0, *)
extension UIGlassEffect.Style: CustomStringConvertible {
    public var description: String {
        switch self {
        case .regular: return "Regular"
        case .clear: return "Clear"
        @unknown default: return "Unknown"
        }
    }
}

@available(iOS 26.0, *)
extension UIGlassEffect {
    var resolvedStyle: UIGlassEffect.Style {
        if responds(to: NSSelectorFromString("style")), let raw = value(forKey: "style") as? Int, let style = UIGlassEffect.Style(rawValue: raw) {
            return style
        }
        let description = String(describing: self).lowercased()
        if description.contains("clear") { return .clear }
        return .regular
    }
}
