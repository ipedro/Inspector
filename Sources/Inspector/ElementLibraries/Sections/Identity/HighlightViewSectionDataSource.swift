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

        var properties: [InspectorElementProperty] {
            guard let highlightView = highlightView else {
                return []
            }

            return Property.allCases.compactMap { property in
                switch property {
                case .highlightView:
                    return .switch(
                        title: property.rawValue,
                        isOn: { !highlightView.isHidden },
                        handler: { isOn in
                            highlightView.isHidden = !isOn
                        }
                    )
                case .nameDisplayMode:
                    return .optionsList(
                        title: property.rawValue,
                        options: ElementNameView.DisplayMode.allCases.map(\.title),
                        selectedIndex: { ElementNameView.DisplayMode.allCases.firstIndex(of: highlightView.displayMode) },
                        handler: {
                            guard let newIndex = $0 else { return }

                            let displayMode = ElementNameView.DisplayMode.allCases[newIndex]

                            highlightView.displayMode = displayMode
                        }
                    )
                }
            }
        }
    }
}
