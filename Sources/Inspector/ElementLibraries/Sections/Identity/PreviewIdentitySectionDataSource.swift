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

extension DefaultElementIdentityLibrary {
    final class PreviewIdentitySectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = Texts.preview

        private let element: ViewHierarchyElement

        private var isHighlightingViews: Bool { element.containsVisibleHighlightViews }

        init(with view: UIView) {
            element = .init(with: view, iconProvider: .default)
        }

        private enum Property: String, Swift.CaseIterable {
            case preview = "Preview"
            case backgroundColor = "Preview Background"
        }

        var properties: [InspectorElementProperty] {
            Property.allCases.compactMap { property in
                switch property {
                case .preview:
                    guard let view = element.underlyingView else { return nil }
                    return .preview(target: .init(view: view))

                case .backgroundColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { Inspector.sharedInstance.configuration.elementInspectorConfiguration.thumbnailBackgroundStyle.color },
                        handler: {
                            guard let color = $0 else { return }
                            Inspector.sharedInstance.configuration.elementInspectorConfiguration.thumbnailBackgroundStyle = .custom(color)
                        }
                    )
                }
            }
        }
    }
}
