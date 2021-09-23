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

struct FontReference: Hashable, CustomStringConvertible, CaseIterable {
    let rawValue: String

    let description: String

    private func font(size: CGFloat) -> UIFont? {
        if rawValue == .systemFontFamilyName {
            return .systemFont(ofSize: size)
        }

        return UIFont(name: rawValue, size: size)
    }

    static let systemFontReference: FontReference = .init(rawValue: .systemFontFamilyName, description: .systemFontFamilyName)

    static func font(at index: Int, size: CGFloat) -> UIFont? {
        guard (0 ..< allCases.count).contains(index) else { return nil }

        let reference = allCases[index]

        return reference.font(size: size)
    }

    static func firstIndex(of fontName: String) -> Int? {
        FontReference.allCases.firstIndex { $0.rawValue == fontName } ?? FontReference.allCases.firstIndex(of: .systemFontReference)
    }

    static let allCases: [FontReference] = {
        var references: [FontReference] = [.systemFontReference]

        for family in UIFont.familyNames.sorted() where family != .systemFontFamilyName {
            for fontName in UIFont.fontNames(forFamilyName: family) {
                let variation = variation(with: fontName)

                let description: String = [family, variation]
                    .compactMap { $0 }
                    .joined(separator: " ")

                let reference = FontReference(rawValue: fontName, description: description)

                references.append(reference)
            }
        }

        return references
    }()

    private static func variation(with fontName: String) -> String? {
        let components = fontName.split(separator: "-")

        guard
            components.count > 1,
            let last = components.last
        else {
            return nil
        }

        return String(last).camelCaseToWords()
    }
}

extension String {
    public static let systemFontFamilyName = "System Font"

    fileprivate func camelCaseToWords() -> String {
        return unicodeScalars.reduce(String()) {
            guard
                CharacterSet.uppercaseLetters.contains($1),
                let previous = $0.last?.unicodeScalars.last,
                CharacterSet.uppercaseLetters.contains(previous) == false
            else {
                return $0 + String($1)
            }

            return "\($0) \($1)"
        }
    }
}
