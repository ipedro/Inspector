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

extension LengthMeasurementView {
    final class ArrowView: BaseView {
        var axis: NSLayoutConstraint.Axis {
            didSet {
                setNeedsDisplay()
            }
        }

        var color: UIColor {
            didSet {
                setNeedsDisplay()
            }
        }

        var gapSize: CGSize = .zero {
            didSet {
                setNeedsDisplay()
            }
        }

        init(axis: NSLayoutConstraint.Axis, color: UIColor, frame: CGRect = .zero) {
            self.axis = axis
            self.color = color

            super.init(frame: frame)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func setup() {
            super.setup()

            autoresizingMask = [.flexibleWidth, .flexibleWidth]

            isOpaque = false

            contentMode = .redraw
        }

        override func draw(_ rect: CGRect) {
            switch axis {
            case .vertical:
                IconKit.drawSizeArrowVertical(color: color, gapHeight: gapSize.height, frame: rect)

            case .horizontal:
                IconKit.drawSizeArrowHorizontal(color: color, gapWidth: gapSize.width, frame: rect)

            @unknown default:
                break
            }
        }
    }
}
