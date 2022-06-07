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

public extension InspectorElementProperty {
    static func fontNamePicker(
        title: String,
        emptyTitle: String = .systemFontFamilyName,
        fontProvider: @escaping FontProvider,
        handler: @escaping FontHandler
    ) -> InspectorElementProperty {
        .optionsList(
            title: title,
            emptyTitle: emptyTitle,
            axis: .vertical,
            options: FontReference.allCases.map(\.description),
            selectedIndex: {
                guard let fontName = fontProvider()?.fontName else { return nil }
                return FontReference.firstIndex(of: fontName)
            },
            handler: {
                guard
                    let newIndex = $0,
                    let pointSize = fontProvider()?.pointSize,
                    let newFont = FontReference.font(at: newIndex, size: pointSize)
                else {
                    return handler(nil)
                }

                handler(newFont)
            }
        )
    }

    static func fontSizeStepper(
        title: String,
        fontProvider: @escaping FontProvider,
        handler: @escaping FontHandler
    ) -> InspectorElementProperty {
        .cgFloatStepper(
            title: title,
            value: { fontProvider()?.pointSize ?? 0 },
            range: { 0...256 },
            stepValue: { 1 }
        ) { fontSize in

            let newFont = fontProvider()?.withSize(fontSize)

            handler(newFont)
        }
    }
}
