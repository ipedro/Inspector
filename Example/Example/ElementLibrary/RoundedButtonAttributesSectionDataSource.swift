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

import Inspector
import InspectorContract
import UIKit

final class RoundedButtonAttributesSectionDataSource: InspectorElementSectionDataSource {
    var state: InspectorElementSectionState = .collapsed

    var title: String = "Rounded Button"

    let button: RoundedButton

    init?(with object: NSObject) {
        guard let button = object as? RoundedButton else {
            return nil
        }
        self.button = button
    }

    enum Properties: String, CaseIterable {
        case animateOnTouch = "Animate On Touch"
        case cornerRadius = "Round Corners"
        case backgroundColor = "Background Color"
    }

    var propertyBindings: [InspectorPropertyBinding] {
        Properties.allCases.map { property in
            switch property {
            case .animateOnTouch:
                .init(
                    descriptor: .init(id: "animate-on-touch", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                    read: { .bool(self.button.animateOnTouch) },
                    write: { newValue in
                        guard case let .bool(animateOnTouch) = newValue else { return }
                        self.button.animateOnTouch = animateOnTouch
                    }
                )
            case .cornerRadius:
                .init(
                    descriptor: .init(id: "round-corners", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                    read: { .bool(self.button.roundCorners) },
                    write: { newValue in
                        guard case let .bool(roundCorners) = newValue else { return }
                        self.button.roundCorners = roundCorners
                    }
                )
            case .backgroundColor:
                .init(
                    descriptor: .init(id: "background-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color(self.button.backgroundColor) },
                    write: { newValue in
                        guard case let .color(newBackgroundColor) = newValue else { return }
                        self.button.backgroundColor = newBackgroundColor
                    }
                )
            }
        }
    }
}
