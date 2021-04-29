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

public extension InspectorElementViewModelProperty {
    
    static func integerStepper(
        title: String,
        value: @escaping IntProvider,
        range: @escaping IntClosedRangeProvider,
        stepValue: @escaping IntProvider,
        handler: IntHandler?
    ) -> InspectorElementViewModelProperty {
        .stepper(
            title: title,
            value: { Double(value()) },
            range: { Double(range().lowerBound)...Double(range().upperBound) },
            stepValue: { Double(stepValue()) },
            isDecimalValue: false
        ) { doubleValue in
            handler?(Int(doubleValue))
        }
    }
    
    static func cgFloatStepper(
        title: String,
        value: @escaping CGFloatProvider,
        range: @escaping CGFloatClosedRangeProvider,
        stepValue: @escaping CGFloatProvider,
        handler: CGFloatHandler?
    ) -> InspectorElementViewModelProperty {
        .stepper(
            title: title,
            value: { Double(value()) },
            range: { Double(range().lowerBound)...Double(range().upperBound) },
            stepValue: { Double(stepValue()) },
            isDecimalValue: true
        ) { doubleValue in
            handler?(CGFloat(doubleValue))
        }
    }
    
    static func floatStepper(
        title: String,
        value: @escaping (() -> Float),
        range: @escaping (() -> ClosedRange<Float>),
        stepValue: @escaping (() -> Float),
        handler: ((Float) -> Void)?
    ) -> InspectorElementViewModelProperty {
        .stepper(
            title: title,
            value: { Double(value()) },
            range: { Double(range().lowerBound)...Double(range().upperBound)} ,
            stepValue: { Double(stepValue()) },
            isDecimalValue: true
        ) { doubleValue in
            handler?(Float(doubleValue))
        }
    }
    
}
