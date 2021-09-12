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
    
    case separator(title: String)
    
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
    
    case toggleButton(title: String,
                      isOn: BoolProvider,
                      handler: BoolHandler?)
}

extension InspectorElementViewModelProperty {
    var isControl: Bool {
        switch self {
        case .stepper,
             .colorPicker,
             .toggleButton,
             .textButtonGroup,
             .imageButtonGroup,
             .optionsList,
             .textField,
             .textView,
             .imagePicker:
            return true
            
        case .group,
             .separator:
            return false
        }
    }
    
    var hasHandler: Bool {
        switch self {
        case .stepper(_, _, _, _, _, .some),
             .colorPicker(_, _, .some),
             .toggleButton(_, _, .some),
             .textButtonGroup(_, _, _, _, .some),
             .imageButtonGroup(_, _, _, _, .some),
             .optionsList(_, _, _, _, _, .some),
             .textField(_, _, _, _, .some),
             .textView(_, _, _, .some),
             .imagePicker(_, _, .some):
            return true
            
        case .stepper,
             .colorPicker,
             .toggleButton,
             .textButtonGroup,
             .imageButtonGroup,
             .optionsList,
             .textField,
             .textView,
             .group,
             .separator,
             .imagePicker:
            return false
        }
    }
}

// MARK: - Value Handlers

public extension InspectorElementViewModelProperty {
    typealias BoolHandler = ((Bool) -> Void)
    typealias CGFloatHandler = ((CGFloat) -> Void)
    typealias ColorHandler = ((UIColor?) -> Void)
    typealias DoubleHandler = ((Double) -> Void)
    typealias FloatHandler = ((Float) -> Void)
    typealias FontHandler = ((UIFont?) -> Void)
    typealias ImageHandler = ((UIImage?) -> Void)
    typealias IntHandler = ((Int) -> Void)
    typealias SelectionHandler = ((Int?) -> Void)
    typealias StringHandler = ((String?) -> Void)
}

// MARK: - Value Providers

public extension InspectorElementViewModelProperty {
    typealias BoolProvider = (() -> Bool)
    typealias CGFloatClosedRangeProvider = (() -> ClosedRange<CGFloat>)
    typealias CGFloatProvider = (() -> CGFloat)
    typealias ColorProvider = (() -> UIColor?)
    typealias DoubleClosedRangeProvider = (() -> ClosedRange<Double>)
    typealias DoubleProvider = (() -> Double)
    typealias FloatClosedRangeProvider = (() -> ClosedRange<Float>)
    typealias FloatProvider = (() -> Float)
    typealias FontProvider = (() -> UIFont?)
    typealias ImageProvider = (() -> UIImage?)
    typealias IntClosedRangeProvider = (() -> ClosedRange<Int>)
    typealias IntProvider = (() -> Int)
    typealias SelectionProvider = (() -> Int?)
    typealias StringProvider = (() -> String?)
}
