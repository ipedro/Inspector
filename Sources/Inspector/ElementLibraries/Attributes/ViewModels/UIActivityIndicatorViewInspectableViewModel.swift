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

extension ElementInspectorAttributesLibrary {
    final class UIActivityIndicatorViewInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case style = "Style"
            case color = "Color"
            case groupBehavior = "Behavior"
            case isAnimating = "Animating"
            case hidesWhenStopped = "Hides When Stopped"
        }

        let title = "Activity Indicator"

        private(set) weak var activityIndicatorView: UIActivityIndicatorView?

        init?(view: UIView) {
            guard let activityIndicatorView = view as? UIActivityIndicatorView else {
                return nil
            }

            self.activityIndicatorView = activityIndicatorView
        }

        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
            guard let activityIndicatorView = activityIndicatorView else {
                return nil
            }

            switch property {
            case .style:
                return .optionsList(
                    title: property.rawValue,
                    options: UIActivityIndicatorView.Style.allCases.map(\.description),
                    selectedIndex: { UIActivityIndicatorView.Style.allCases.firstIndex(of: activityIndicatorView.style) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }

                    let style = UIActivityIndicatorView.Style.allCases[newIndex]

                    activityIndicatorView.style = style
                }
            case .color:
                return .colorPicker(
                    title: property.rawValue,
                    color: { activityIndicatorView.color }
                ) {
                    guard let color = $0 else {
                        return
                    }

                    activityIndicatorView.color = color
                }

            case .groupBehavior:
                return .group(title: property.rawValue)

            case .isAnimating:
                return .switch(
                    title: property.rawValue,
                    isOn: { activityIndicatorView.isAnimating }
                ) { isAnimating in

                    switch isAnimating {
                    case true:
                        activityIndicatorView.startAnimating()

                    case false:
                        activityIndicatorView.stopAnimating()
                    }
                }

            case .hidesWhenStopped:
                return .switch(
                    title: property.rawValue,
                    isOn: { activityIndicatorView.hidesWhenStopped }
                ) { hidesWhenStopped in
                    activityIndicatorView.hidesWhenStopped = hidesWhenStopped
                }
            }
        }
    }
}
