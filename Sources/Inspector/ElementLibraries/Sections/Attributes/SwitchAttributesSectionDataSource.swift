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

extension ElementAttributesLibrary {
    final class SwitchAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Switch"

        private weak var switchControl: UISwitch?

        init?(with object: NSObject) {
            guard let switchControl = object as? UISwitch else { return nil }

            self.switchControl = switchControl
        }

        private enum Property: String, Swift.CaseIterable {
            case title = "Title"
            case preferredStyle = "Preferred Style"
            case isOn = "State"
            case onTintColor = "On Tint"
            case thumbTintColor = "Thumb Tint"
        }

        var properties: [InspectorElementProperty] {
            guard let switchControl = switchControl else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .title:
                    guard #available(iOS 14.0, *) else { return nil }

                    return .textField(
                        title: property.rawValue,
                        placeholder: switchControl.title.isNilOrEmpty ? property.rawValue : switchControl.title,
                        value: { switchControl.title }
                    ) { title in
                        switchControl.title = title
                    }
                case .preferredStyle:
                    guard #available(iOS 14.0, *) else { return nil }

                    return .textButtonGroup(
                        title: property.rawValue,
                        texts: UISwitch.Style.allCases.map(\.description),
                        selectedIndex: { UISwitch.Style.allCases.firstIndex(of: switchControl.preferredStyle) },
                        handler: {
                            guard let newIndex = $0 else { return }

                            let preferredStyle = UISwitch.Style.allCases[newIndex]

                            switchControl.preferredStyle = preferredStyle
                        }
                    )
                case .isOn:
                    return .switch(
                        title: property.rawValue,
                        isOn: { switchControl.isOn }
                    ) { isOn in
                        switchControl.setOn(isOn, animated: true)
                        switchControl.sendActions(for: .valueChanged)
                    }
                case .onTintColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { switchControl.onTintColor }
                    ) { onTintColor in
                        switchControl.onTintColor = onTintColor
                    }
                case .thumbTintColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { switchControl.thumbTintColor }
                    ) { thumbTintColor in
                        switchControl.thumbTintColor = thumbTintColor
                    }
                }
            }
        }
    }
}
