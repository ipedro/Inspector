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

public extension InspectorElementViewModelProperty {
    static func fontNamePicker(
        title: String,
        emptyTitle: String = "System Font",
        fontProvider: @escaping FontProvider,
        handler: @escaping FontHandler
    ) -> InspectorElementViewModelProperty {
        typealias FontReference = (fontName: String, displayName: String)

        let availableFonts: [FontReference] = {
            var array = [FontReference("", emptyTitle)]

            UIFont.familyNames.forEach { familyName in

                let familyNames = UIFont.fontNames(forFamilyName: familyName)

                if
                    familyNames.count == 1,
                    let fontName = familyNames.first
                {
                    array.append((fontName: fontName, displayName: familyName))
                    return
                }

                familyNames.forEach { fontName in
                    guard
                        let lastName = fontName.split(separator: "-").last,
                        lastName.replacingOccurrences(of: " ", with: "")
                        .caseInsensitiveCompare(familyName.replacingOccurrences(of: " ", with: "")) != .orderedSame
                    else {
                        array.append((fontName: fontName, displayName: fontName))
                        return
                    }

                    array.append((fontName: fontName, displayName: "\(familyName) \(lastName)"))
                }
            }

            return array
        }()

        return .optionsList(
            title: title,
            emptyTitle: emptyTitle,
            axis: .vertical,
            options: availableFonts.map(\.displayName),
            selectedIndex: { availableFonts.firstIndex { $0.fontName == fontProvider()?.fontName } }
        ) {
            guard let newIndex = $0 else {
                return
            }

            let fontNames = availableFonts.map(\.fontName)
            let fontName = fontNames[newIndex]

            guard let pointSize = fontProvider()?.pointSize else {
                return
            }

            let newFont = UIFont(name: fontName, size: pointSize)

            handler(newFont)
        }
    }

    static func fontSizeStepper(
        title: String,
        fontProvider: @escaping FontProvider,
        handler: @escaping FontHandler
    ) -> InspectorElementViewModelProperty {
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
