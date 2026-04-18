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
    final class LabelSizeSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = "Label"

        private weak var label: UILabel?

        init?(with object: NSObject) {
            guard let label = object as? UILabel else { return nil }
            self.label = label
        }

        private enum Properties: String, Swift.CaseIterable {
            case preferredMaxLayoutWidth = "Desired Width"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let label else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .preferredMaxLayoutWidth:
                    .init(
                        descriptor: .init(
                            id: "preferred-max-layout-width",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(min: 0, step: 1, isDecimal: true)),
                            editability: .editable
                        ),
                        read: { .number(Double(label.preferredMaxLayoutWidth)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            label.preferredMaxLayoutWidth = CGFloat(value)
                        }
                    )
                }
            }
        }
    }
}
