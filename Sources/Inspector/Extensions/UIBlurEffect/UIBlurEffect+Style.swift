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

extension UIBlurEffect {
    var style: Style? {
        let description = self.description

        if description.contains("UIBlurEffectStyleExtraLight") {
            return .extraLight
        }
        if description.contains("UIBlurEffectStyleLight") {
            return .light
        }
        if description.contains("UIBlurEffectStyleDark") {
            return .dark
        }
        if description.contains("UIBlurEffectStyleRegular") {
            return .regular
        }
        if description.contains("UIBlurEffectStyleProminent") {
            return .prominent
        }

        guard #available(iOS 13.0, *) else { return nil }

        if description.contains("UIBlurEffectStyleSystemUltraThinMaterialLight") {
            return .systemUltraThinMaterialLight
        }
        if description.contains("UIBlurEffectStyleSystemThinMaterialLight") {
            return .systemThinMaterialLight
        }
        if description.contains("UIBlurEffectStyleSystemMaterialLight") {
            return .systemMaterialLight
        }
        if description.contains("UIBlurEffectStyleSystemThickMaterialLight") {
            return .systemThickMaterialLight
        }
        if description.contains("UIBlurEffectStyleSystemChromeMaterialLight") {
            return .systemChromeMaterialLight
        }
        if description.contains("UIBlurEffectStyleSystemUltraThinMaterialDark") {
            return .systemUltraThinMaterialDark
        }
        if description.contains("UIBlurEffectStyleSystemThinMaterialDark") {
            return .systemThinMaterialDark
        }
        if description.contains("UIBlurEffectStyleSystemMaterialDark") {
            return .systemMaterialDark
        }
        if description.contains("UIBlurEffectStyleSystemThickMaterialDark") {
            return .systemThickMaterialDark
        }
        if description.contains("UIBlurEffectStyleSystemChromeMaterialDark") {
            return .systemChromeMaterialDark
        }
        if description.contains("UIBlurEffectStyleSystemUltraThinMaterial") {
            return .systemUltraThinMaterial
        }
        if description.contains("UIBlurEffectStyleSystemThinMaterial") {
            return .systemThinMaterial
        }
        if description.contains("UIBlurEffectStyleSystemMaterial") {
            return .systemMaterial
        }
        if description.contains("UIBlurEffectStyleSystemThickMaterial") {
            return .systemThickMaterial
        }
        if description.contains("UIBlurEffectStyleSystemChromeMaterial") {
            return .systemChromeMaterial
        }

        return nil
    }
}
