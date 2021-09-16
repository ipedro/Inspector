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

struct ViewFrameInspectableViewModel: InspectorElementViewModelProtocol {
    private enum Properties: String, Swift.CaseIterable {
        case frame = "Frame Rectangle"
        case autoresizingMask = "View Resizing"
    }

    let title: String = "View"

    private let view: UIView

    init(view: UIView) {
        self.view = view
    }

    var properties: [InspectorElementViewModelProperty] {
        Properties.allCases.map { property in
            switch property {
            case .frame:
                return .cgRect(
                    title: property.rawValue,
                    value: { view.frame },
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
                        guard let index = $0 else { return }

                        let autoresizingMask = UIView.AutoresizingMask.allCases[index]
                        view.autoresizingMask = autoresizingMask
                    }
                )
            }
        }
    }
}

extension UIView.AutoresizingMask: CaseIterable {
    typealias AllCases = [UIView.AutoresizingMask]

    static let allCases: [UIView.AutoresizingMask] = [
        .flexibleLeftMargin,
        .flexibleWidth,
        .flexibleRightMargin,
        .flexibleTopMargin,
        .flexibleHeight,
        .flexibleBottomMargin,
    ]
}

extension UIView.AutoresizingMask: CustomStringConvertible {
    var name: String {
        switch self {
        case .flexibleWidth:
            return "Width"
        case .flexibleLeftMargin:
            return "Left Margin"
        case .flexibleWidth:
            return "Width"
        case .flexibleRightMargin:
            return "Right Margin"
        case .flexibleTopMargin:
            return "Top Margin"
        case .flexibleHeight:
            return "Height"
        case .flexibleBottomMargin:
            return "Bottom Margin"
        default:
            return String(describing: rawValue)
        }
    }

    var description: String {
        var strings = [String]()

        for mask in Self.allCases where self.contains(mask) {
            strings.append(mask.name)
        }

        return "Flexible \(strings.joined(separator: ", "))"
    }
}
