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

extension DefaultElementAttributesLibrary {
    final class ActivityIndicatorViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Activity Indicator"

        private weak var activityIndicatorView: UIActivityIndicatorView?

        init?(with object: NSObject) {
            guard let activityIndicatorView = object as? UIActivityIndicatorView else { return nil }

            self.activityIndicatorView = activityIndicatorView
        }

        private enum Property: String, Swift.CaseIterable {
            case style = "Style"
            case color = "Color"
            case groupBehavior = "Behavior"
            case isAnimating = "Animating"
            case hidesWhenStopped = "Hides When Stopped"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let activityIndicatorView else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .style:
                    .init(
                        descriptor: .init(
                            id: "style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIActivityIndicatorView.Style.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIActivityIndicatorView.Style.allCases.firstIndex(of: activityIndicatorView.style)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let style = UIActivityIndicatorView.Style.allCases[newIndex]

                            activityIndicatorView.style = style
                        }
                    )

                case .color:
                    .init(
                        descriptor: .init(
                            id: "color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(activityIndicatorView.color) },
                        write: { newValue in
                            guard case let .color(color) = newValue, let color else { return }
                            activityIndicatorView.color = color
                        }
                    )

                case .groupBehavior:
                    .init(
                        descriptor: .init(
                            id: "behavior-group",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )

                case .isAnimating:
                    .init(
                        descriptor: .init(
                            id: "is-animating",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(activityIndicatorView.isAnimating) },
                        write: { newValue in
                            guard case let .bool(isAnimating) = newValue else { return }
                            switch isAnimating {
                            case true:
                                activityIndicatorView.startAnimating()

                            case false:
                                activityIndicatorView.stopAnimating()
                            }
                        }
                    )

                case .hidesWhenStopped:
                    .init(
                        descriptor: .init(
                            id: "hides-when-stopped",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(activityIndicatorView.hidesWhenStopped) },
                        write: { newValue in
                            guard case let .bool(hidesWhenStopped) = newValue else { return }
                            activityIndicatorView.hidesWhenStopped = hidesWhenStopped
                        }
                    )
                }
            }
        }
    }
}
