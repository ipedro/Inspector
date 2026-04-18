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
    final class SegmentedControlSizeSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = "Segmented Control"

        private var selectedSegment: Int?

        private weak var segmentedControl: UISegmentedControl?

        init?(with object: NSObject) {
            guard let segmentedControl = object as? UISegmentedControl else {
                return nil
            }

            self.segmentedControl = segmentedControl

            selectedSegment = segmentedControl.numberOfSegments == 0 ? nil : 0
        }

        private enum Properties: String, Swift.CaseIterable {
            case segmentPicker = "Segment"
            case segmentWidth = "Width"
            case separator
            case apportionsSegmentWidthsByContent = "Size Mode"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let segmentedControl else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .segmentPicker:
                    .init(
                        descriptor: .init(
                            id: "segment-picker",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: (0..<segmentedControl.numberOfSegments).map {
                                    .init(id: "\($0)", title: "Segment \($0)")
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { [weak self] in .selection(self?.selectedSegment) },
                        write: { [weak self] newValue in
                            guard case let .selection(selectedSegment) = newValue else { return }
                            self?.selectedSegment = selectedSegment
                        }
                    )
                case .segmentWidth:
                    .init(
                        descriptor: .init(
                            id: "segment-width",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(min: 0, max: Double(segmentedControl.frame.width), step: 1, isDecimal: true)),
                            editability: .editable
                        ),
                        read: { [weak self] in
                            guard let index = self?.selectedSegment else { return .number(.zero) }
                            return .number(Double(segmentedControl.widthForSegment(at: index)))
                        },
                        write: { [weak self] newValue in
                            guard case let .number(segmentWidth) = newValue else { return }
                            guard let index = self?.selectedSegment else { return }
                            segmentedControl.setWidth(CGFloat(segmentWidth), forSegmentAt: index)
                        }
                    )
                case .apportionsSegmentWidthsByContent:
                    .init(
                        descriptor: .init(
                            id: "apportions-segment-widths",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: [
                                    .init(id: "0", title: "Equal Widths"),
                                    .init(id: "1", title: "Proportional to Content")
                                ], allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(segmentedControl.apportionsSegmentWidthsByContent ? 1 : 0) },
                        write: { newValue in
                            guard case let .selection(newIndex) = newValue else { return }
                            segmentedControl.apportionsSegmentWidthsByContent = newIndex == 1
                        }
                    )
                case .separator:
                    .init(
                        descriptor: .init(
                            id: "separator",
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                }
            }
        }
    }
}
