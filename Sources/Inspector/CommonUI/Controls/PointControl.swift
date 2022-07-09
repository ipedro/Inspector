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

final class PointControl: StepperPairControl<CGFloat> {
    private var x: CGFloat {
        get { firstValue }
        set { firstValue = newValue }
    }

    private var y: CGFloat {
        get { secondValue }
        set { secondValue = newValue }
    }

    var point: CGPoint {
        get {
            CGPoint(
                x: x,
                y: y
            )
        }
        set {
            x = newValue.x
            y = newValue.y
        }
    }

    override var title: String? {
        didSet {
            firstSubtitle = "X".string(prepending: title)
            secondSubtitle = "Y".string(prepending: title)
        }
    }

    convenience init(title: String?, point: CGPoint) {
        self.init(
            firstValue: point.x,
            firstRange: -Double.infinity...Double.infinity,
            secondValue: point.y,
            secondRange: -Double.infinity...Double.infinity
        )
        self.title = title
    }
}
