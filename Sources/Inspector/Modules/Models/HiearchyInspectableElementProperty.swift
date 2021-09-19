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

public enum InspectorElementViewModelProperty {
    case colorPicker(title: String,
                     color: ColorProvider,
                     handler: ColorHandler?)

    case group(title: String)

    case separator

    case imagePicker(title: String,
                     image: ImageProvider,
                     handler: ImageHandler?)

    case optionsList(title: String,
                     emptyTitle: String = "Unspecified",
                     axis: NSLayoutConstraint.Axis = .horizontal,
                     options: [String],
                     selectedIndex: SelectionProvider,
                     handler: SelectionHandler?)

    case textButtonGroup(title: String,
                         axis: NSLayoutConstraint.Axis = .vertical,
                         texts: [String],
                         selectedIndex: SelectionProvider,
                         handler: SelectionHandler?)

    case imageButtonGroup(title: String,
                          axis: NSLayoutConstraint.Axis = .vertical,
                          images: [UIImage],
                          selectedIndex: SelectionProvider,
                          handler: SelectionHandler?)

    case stepper(title: String,
                 value: DoubleProvider,
                 range: DoubleClosedRangeProvider,
                 stepValue: DoubleProvider,
                 isDecimalValue: Bool,
                 handler: DoubleHandler?)

    case textField(title: String,
                   placeholder: String?,
                   axis: NSLayoutConstraint.Axis = .vertical,
                   value: StringProvider,
                   handler: StringHandler?)

    case textView(title: String,
                  placeholder: String?,
                  value: StringProvider,
                  handler: StringHandler?)

    case `switch`(title: String,
                  isOn: BoolProvider,
                  handler: BoolHandler?)

    case cgRect(title: String,
                rect: CGRectProvider,
                handler: CGRectHandler?)

    case cgPoint(title: String,
                 point: CGPointProvider,
                 handler: CGPointHandler?)

    case cgSize(title: String,
                size: CGSizeProvider,
                handler: CGSizeHandler?)

    case directionalInsets(title: String,
                           insets: NSDirectionalEdgeInsetsProvider,
                           handler: NSDirectionalEdgeInsetsHandler?)

    @available(*, deprecated, message: "Use `switch(title:isOn:handler:)` instead, this will be removed at a later version.")
    public static func toggleControl(title: String,
                                     isOn: @escaping BoolProvider,
                                     handler: BoolHandler?) -> InspectorElementViewModelProperty {
        .switch(title: title, isOn: isOn, handler: handler)
    }
}

extension InspectorElementViewModelProperty {
    var isControl: Bool {
        switch self {
        case .group, .separator:
            return false

        default:
            return true
        }
    }

    var hasHandler: Bool {
        switch self {
        case .stepper(_, _, _, _, _, .some),
             .colorPicker(_, _, .some),
             .switch(_, _, .some),
             .textButtonGroup(_, _, _, _, .some),
             .imageButtonGroup(_, _, _, _, .some),
             .optionsList(_, _, _, _, _, .some),
             .textField(_, _, _, _, .some),
             .textView(_, _, _, .some),
             .imagePicker(_, _, .some),
             .cgRect(_, _, .some),
             .cgSize(_, _, .some),
             .cgPoint(_, _, .some),
             .directionalInsets(_, _, .some):
            return true

        case .stepper,
             .colorPicker,
             .switch,
             .textButtonGroup,
             .imageButtonGroup,
             .optionsList,
             .textField,
             .textView,
             .group,
             .separator,
             .imagePicker,
             .cgRect,
             .cgSize,
             .cgPoint,
             .directionalInsets:
            return false
        }
    }
}

// MARK: - Value Handlers

public extension InspectorElementViewModelProperty {
    typealias Handler<Value> = ((Value) -> Void)

    typealias NSDirectionalEdgeInsetsHandler = Handler<NSDirectionalEdgeInsets>
    typealias BoolHandler = Handler<Bool>
    typealias CGColorHandler = Handler<CGColor?>
    typealias CGFloatHandler = Handler<CGFloat>
    typealias CGPointHandler = Handler<CGPoint?>
    typealias CGRectHandler = Handler<CGRect?>
    typealias CGSizeHandler = Handler<CGSize?>
    typealias ColorHandler = Handler<UIColor?>
    typealias DoubleHandler = Handler<Double>
    typealias FloatHandler = Handler<Float>
    typealias FontHandler = Handler<UIFont?>
    typealias ImageHandler = Handler<UIImage?>
    typealias IntHandler = Handler<Int>
    typealias SelectionHandler = Handler<Int?>
    typealias StringHandler = Handler<String?>
}

// MARK: - Value Providers

public extension InspectorElementViewModelProperty {
    typealias Provider<Value> = (() -> Value)

    typealias NSDirectionalEdgeInsetsProvider = Provider<NSDirectionalEdgeInsets>
    typealias BoolProvider = Provider<Bool>
    typealias CGColorProvider = Provider<CGColor?>
    typealias CGFloatClosedRangeProvider = Provider<ClosedRange<CGFloat>>
    typealias CGFloatProvider = Provider<CGFloat>
    typealias CGPointProvider = Provider<CGPoint>
    typealias CGRectProvider = Provider<CGRect>
    typealias CGSizeProvider = Provider<CGSize>
    typealias ColorProvider = Provider<UIColor?>
    typealias DoubleClosedRangeProvider = Provider<ClosedRange<Double>>
    typealias DoubleProvider = Provider<Double>
    typealias FloatClosedRangeProvider = Provider<ClosedRange<Float>>
    typealias FloatProvider = Provider<Float>
    typealias FontProvider = Provider<UIFont?>
    typealias ImageProvider = Provider<UIImage?>
    typealias IntClosedRangeProvider = Provider<ClosedRange<Int>>
    typealias IntProvider = Provider<Int>
    typealias SelectionProvider = Provider<Int?>
    typealias StringProvider = Provider<String?>
}
