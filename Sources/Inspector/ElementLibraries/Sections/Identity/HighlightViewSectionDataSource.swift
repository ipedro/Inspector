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
    final class HighlightViewSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = Texts.highlight("View")

        weak var highlightView: HighlightView?

        init?(with view: UIView) {
            if let highlightView = view._highlightView {
                self.highlightView = highlightView
            }
            else {
                return nil
            }
        }

        private enum Property: String, Swift.CaseIterable {
            case nameDisplayMode = "Name Display"
            case highlightView = "Show Highlight"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let highlightView else {
                return []
            }

            return Property.allCases.compactMap { property in
                switch property {
                case .highlightView:
                    .init(
                        descriptor: .init(
                            id: "show-highlight",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(!highlightView.isHidden) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            highlightView.isHidden = !isOn
                        }
                    )
                case .nameDisplayMode:
                    .init(
                        descriptor: .init(
                            id: "name-display-mode",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: ElementNameView.DisplayMode.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.title)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(ElementNameView.DisplayMode.allCases.firstIndex(of: highlightView.displayMode)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let displayMode = ElementNameView.DisplayMode.allCases[newIndex]

                            highlightView.displayMode = displayMode
                        }
                    )
                }
            }
        }
    }
}
