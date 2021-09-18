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

final class CGSizeStepperControl: StepperPairControl<CGFloat> {
    private var width: CGFloat {
        get { firstValue }
        set { firstValue = newValue }
    }

    private var height: CGFloat {
        get { secondValue }
        set { secondValue = newValue }
    }

    var size: CGSize {
        get {
            CGSize(
                width: width,
                height: height
            )
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }

    override var title: String? {
        get { _title }
        set { _title = newValue }
    }

    private var _title: String? {
        didSet {
            firstSubtitle = "Width".string(prepending: _title, separator: " ")
            secondSubtitle = "Height".string(prepending: _title, separator: " ")
        }
    }

    convenience init(title: String?, size: CGSize?) {
        self.init(firstValue: size?.width ?? .zero, secondValue: size?.height ?? .zero)
        self.title = title
    }
}
