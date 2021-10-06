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

extension ElementInspectorSizeLibrary {
    final class UIViewFrameInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Properties: String, Swift.CaseIterable {
            case frame = "Frame Rectangle"
            case autoresizingMask = "View Resizing"
            case directionalLayoutsMargins = "Layout Margins"
        }

        let title: String = "View"

        private weak var view: UIView?

        init(view: UIView) {
            self.view = view
        }

        var properties: [InspectorElementViewModelProperty] {
            guard let view = view else { return [] }

            return Properties.allCases.compactMap { property in
                switch property {
                case .frame:
                    return .cgRect(
                        title: property.rawValue,
                        rect: { view.frame },
                        handler: {
                            guard let newFrame = $0 else { return }
                            view.frame = newFrame
                        }
                    )

                case .autoresizingMask:
                    return .optionsList(
                        title: property.rawValue,
                        options: UIView.AutoresizingMask.allCases.map(\.description),
                        selectedIndex: { UIView.AutoresizingMask.allCases.firstIndex(of: view.autoresizingMask) },
                        handler: {
                            guard let newIndex = $0 else { return }

                            let autoresizingMask = UIView.AutoresizingMask.allCases[newIndex]
                            view.autoresizingMask = autoresizingMask
                        }
                    )

                case .directionalLayoutsMargins:
                    return .directionalInsets(
                        title: property.rawValue,
                        insets: { view.directionalLayoutMargins },
                        handler: { directionalLayoutMargins in
                            view.directionalLayoutMargins = directionalLayoutMargins
                        }
                    )
                }
            }
        }
    }
}
