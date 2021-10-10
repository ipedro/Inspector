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

extension ElementSizeLibrary {
    final class SegmentedControlSizeSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = "Segmented Control"

        private var selectedSegment: Int?

        private weak var segmentedControl: UISegmentedControl?

        init?(view: UIView) {
            guard let segmentedControl = view as? UISegmentedControl else {
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

        var properties: [InspectorElementProperty] {
            guard let segmentedControl = segmentedControl else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .segmentPicker:
                    return .segmentPicker(for: segmentedControl) { [weak self] selectedSegment in
                        self?.selectedSegment = selectedSegment
                    }
                case .segmentWidth:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { [weak self] in
                            guard let index = self?.selectedSegment else {
                                return .zero
                            }
                            return segmentedControl.widthForSegment(at: index)
                        },
                        range: { 0...segmentedControl.frame.width },
                        stepValue: { 1 },
                        handler: { [weak self] segmentWidth in
                            guard let index = self?.selectedSegment else {
                                return
                            }
                            segmentedControl.setWidth(segmentWidth, forSegmentAt: index)
                        }
                    )
                case .apportionsSegmentWidthsByContent:
                    return .optionsList(
                        title: property.rawValue,
                        options: ["Equal Widths", "Proportional to Content"],
                        selectedIndex: { segmentedControl.apportionsSegmentWidthsByContent ? 1 : 0 },
                        handler: { newIndex in
                            segmentedControl.apportionsSegmentWidthsByContent = newIndex == 1
                        }
                    )
                case .separator:
                    return .separator
                }
            }
        }
    }
}
