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
    final class UILabelSizeAttributesViewModel: InspectorElementViewModelProtocol {
        private enum Properties: String, Swift.CaseIterable {
            case preferredMaxLayoutWidth = "Desired Width"
        }

        let title: String = "Label"

        private weak var label: UILabel?

        init?(view: UIView) {
            guard let label = view as? UILabel else { return nil }
            self.label = label
        }

        var properties: [InspectorElementViewModelProperty] {
            guard let label = label else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .preferredMaxLayoutWidth:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { label.preferredMaxLayoutWidth },
                        range: { 0...Double.infinity },
                        stepValue: { 1 },
                        handler: { label.preferredMaxLayoutWidth = $0 }
                    )
                }
            }
        }
    }
}
