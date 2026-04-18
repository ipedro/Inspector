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

import InspectorContract
import UIKit

extension DefaultElementSizeLibrary {
    final class ViewFrameSizeSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = "View"

        private weak var view: UIView?

        init?(with object: NSObject) {
            guard let view = object as? UIView else { return nil }

            self.view = view
        }

        private enum Properties: String, Swift.CaseIterable {
            case frame = "Frame Rectangle"
            case autoresizingMask = "View Resizing"
            case directionalLayoutsMargins = "Layout Margins"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let view else { return [] }

            return Properties.allCases.compactMap { property in
                switch property {
                case .frame:
                    .init(
                        descriptor: .init(
                            id: "frame",
                            title: property.rawValue,
                            kind: .preview,
                            value: .rect,
                            editability: .editable
                        ),
                        read: { .rect(view.frame) },
                        write: { newValue in
                            guard case let .rect(newFrame) = newValue else { return }
                            view.frame = newFrame
                        }
                    )

                case .autoresizingMask:
                    .init(
                        descriptor: .init(
                            id: "autoresizing-mask",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIView.AutoresizingMask.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIView.AutoresizingMask.allCases.firstIndex(of: view.autoresizingMask)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let autoresizingMask = UIView.AutoresizingMask.allCases[newIndex]
                            view.autoresizingMask = autoresizingMask
                        }
                    )

                case .directionalLayoutsMargins:
                    .init(
                        descriptor: .init(
                            id: "directional-layout-margins",
                            title: property.rawValue,
                            kind: .preview,
                            value: .directionalEdgeInsets,
                            editability: .editable
                        ),
                        read: { .directionalEdgeInsets(view.directionalLayoutMargins) },
                        write: { newValue in
                            guard case let .directionalEdgeInsets(directionalLayoutMargins) = newValue else { return }
                            view.directionalLayoutMargins = directionalLayoutMargins
                        }
                    )
                }
            }
        }
    }
}
