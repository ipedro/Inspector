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

extension UIImage {
    static func icon(_ name: String) -> UIImage? {
        UIImage(named: name, in: .module, compatibleWith: nil)
    }
}

extension UIImage {
    static func systemIcon(
        _ systemName: String,
        weight: UIImage.SymbolWeight = .light,
        render renderingMode: UIImage.RenderingMode = .alwaysTemplate,
        prefersHierarchicalColor: Bool = true
    ) -> UIImage? {
        let image = UIImage(systemName: systemName)?
            .withRenderingMode(renderingMode)

        if #available(iOS 15.0, *), prefersHierarchicalColor {
            return image?
                .applyingSymbolConfiguration(
                    .init(weight: weight)
                )?
                .applyingSymbolConfiguration(
                    .init(hierarchicalColor: Inspector.sharedInstance.configuration.colorStyle.textColor)
                )
        }
        else {
            return image?
                .applyingSymbolConfiguration(
                    .init(weight: weight)
                )
        }
    }
}
