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

extension ElementSizeLibrary {
    final class ButtonSizeSectionDataSource: InspectorElementSectionDataSource {
        private enum Properties: String, Swift.CaseIterable {
            case contentEdgeInsets = "Content Insets"
            case titleEdgeInsets = "Title Insets"
            case imageEdgeInsets = "Image Insets"
        }

        let title: String = "Button"

        private weak var button: UIButton?

        init?(view: UIView) {
            guard let button = view as? UIButton else { return nil }
            self.button = button
        }

        var properties: [InspectorElementProperty] {
            guard let button = button else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .contentEdgeInsets:
                    return .edgeInsets(
                        title: property.rawValue,
                        insets: { button.contentEdgeInsets },
                        handler: { button.contentEdgeInsets = $0 }
                    )
                case .imageEdgeInsets:
                    return .edgeInsets(
                        title: property.rawValue,
                        insets: { button.imageEdgeInsets },
                        handler: { button.imageEdgeInsets = $0 }
                    )
                case .titleEdgeInsets:
                    return .edgeInsets(
                        title: property.rawValue,
                        insets: { button.titleEdgeInsets },
                        handler: { button.titleEdgeInsets = $0 }
                    )
                }
            }
        }
    }
}
