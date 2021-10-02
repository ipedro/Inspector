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

extension UIViewElementLibrary {
    final class UISegmentedControlInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case selectedSegmentTintColor = "Selected Tint"
            case isMomentary = "Momentary"
            case isSpringLoaded = "Spring Loaded"
            case groupSegment = "Segment Group"
            case segmentPicker = "Segment"
            case segmentTitle = "Title"
            case segmentImage = "Image"
            case segmentIsEnabled = "Enabled"
            case segmentIsSelected = "Selected"
        }

        let title = "Segmented Control"

        private(set) weak var segmentedControl: UISegmentedControl?

        init?(view: UIView) {
            guard let segmentedControl = view as? UISegmentedControl else {
                return nil
            }

            self.segmentedControl = segmentedControl

            selectedSegment = segmentedControl.numberOfSegments == 0 ? nil : 0
        }

        private var segmentsOptions: [CustomStringConvertible] {
            guard let segmentedControl = segmentedControl else {
                return []
            }

            var options = [String]()

            for index in 0 ..< segmentedControl.numberOfSegments {
                var title: String {
                    let segmentIndex = "Segment \(index)"

                    guard let titleForSegment = segmentedControl.titleForSegment(at: index) else {
                        return segmentIndex
                    }

                    return segmentIndex + " – " + titleForSegment
                }

                options.append(title)
            }

            return options
        }

        private var selectedSegment: Int?

        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
            guard let segmentedControl = segmentedControl else {
                return nil
            }

            switch property {
            case .selectedSegmentTintColor:
                if #available(iOS 13.0, *) {
                    return .colorPicker(
                        title: property.rawValue,
                        color: { segmentedControl.selectedSegmentTintColor }
                    ) { selectedSegmentTintColor in
                        segmentedControl.selectedSegmentTintColor = selectedSegmentTintColor
                    }
                }

                return nil

            case .isMomentary:
                return .switch(
                    title: property.rawValue,
                    isOn: { segmentedControl.isMomentary }
                ) { isMomentary in
                    segmentedControl.isMomentary = isMomentary
                }

            case .isSpringLoaded:
                return .switch(
                    title: property.rawValue,
                    isOn: { segmentedControl.isSpringLoaded }
                ) { isSpringLoaded in
                    segmentedControl.isSpringLoaded = isSpringLoaded
                }

            case .groupSegment:
                return .separator

            case .segmentPicker:
                return .optionsList(
                    title: property.rawValue,
                    emptyTitle: "No Segments",
                    options: segmentsOptions.map(\.description),
                    selectedIndex: { [weak self] in self?.selectedSegment }
                ) { [weak self] selectedSegment in

                    self?.selectedSegment = selectedSegment
                }

            case .segmentTitle:
                return .textField(
                    title: property.rawValue,
                    placeholder: property.rawValue,
                    value: { [weak self] in

                        guard let selectedSegment = self?.selectedSegment else {
                            return nil
                        }

                        return segmentedControl.titleForSegment(at: selectedSegment)
                    }
                ) { [weak self] segmentTitle in

                    guard let selectedSegment = self?.selectedSegment else {
                        return
                    }

                    segmentedControl.setTitle(segmentTitle, forSegmentAt: selectedSegment)
                }

            case .segmentImage:
                return .imagePicker(
                    title: property.rawValue,
                    image: { [weak self] in

                        guard let selectedSegment = self?.selectedSegment else {
                            return nil
                        }

                        return segmentedControl.imageForSegment(at: selectedSegment)
                    }
                ) { [weak self] segmentImage in

                    guard let selectedSegment = self?.selectedSegment else {
                        return
                    }

                    segmentedControl.setImage(segmentImage, forSegmentAt: selectedSegment)
                }

            case .segmentIsEnabled:
                return .switch(
                    title: property.rawValue,
                    isOn: { [weak self] in

                        guard let selectedSegment = self?.selectedSegment else {
                            return false
                        }

                        return segmentedControl.isEnabledForSegment(at: selectedSegment)
                    }
                ) { [weak self] isEnabled in

                    guard let selectedSegment = self?.selectedSegment else {
                        return
                    }

                    segmentedControl.setEnabled(isEnabled, forSegmentAt: selectedSegment)
                }

            case .segmentIsSelected:
                return .switch(
                    title: property.rawValue,
                    isOn: { [weak self] in self?.selectedSegment == segmentedControl.selectedSegmentIndex }
                ) { [weak self] isSelected in

                    guard let selectedSegment = self?.selectedSegment else {
                        return
                    }

                    switch isSelected {
                    case true:
                        segmentedControl.selectedSegmentIndex = selectedSegment

                    case false:
                        segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
                    }
                }
            }
        }
    }
}
