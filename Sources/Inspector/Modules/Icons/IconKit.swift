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

class IconKit: NSObject {
    // MARK: - Canvas Drawings

    /// Icons

    class func drawBorderStyleRoundedRect(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 20, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 20, y: resizedFrame.height / 16)

        /// Icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 15.5, y: 0))
        icon.addCurve(to: CGPoint(x: 20, y: 4.5), controlPoint1: CGPoint(x: 17.99, y: 0), controlPoint2: CGPoint(x: 20, y: 2.01))
        icon.addCurve(to: CGPoint(x: 15.5, y: 9), controlPoint1: CGPoint(x: 20, y: 6.99), controlPoint2: CGPoint(x: 17.99, y: 9))
        icon.addLine(to: CGPoint(x: 4.5, y: 9))
        icon.addCurve(to: CGPoint(x: 0, y: 4.5), controlPoint1: CGPoint(x: 2.01, y: 9), controlPoint2: CGPoint(x: 0, y: 6.99))
        icon.addCurve(to: CGPoint(x: 4.5, y: 0), controlPoint1: CGPoint(x: 0, y: 2.01), controlPoint2: CGPoint(x: 2.01, y: 0))
        icon.addLine(to: CGPoint(x: 15.5, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 15.5, y: 1))
        icon.addLine(to: CGPoint(x: 4.5, y: 1))
        icon.addCurve(to: CGPoint(x: 1, y: 4.5), controlPoint1: CGPoint(x: 2.57, y: 1), controlPoint2: CGPoint(x: 1, y: 2.57))
        icon.addCurve(to: CGPoint(x: 4.5, y: 8), controlPoint1: CGPoint(x: 1, y: 6.43), controlPoint2: CGPoint(x: 2.57, y: 8))
        icon.addLine(to: CGPoint(x: 15.5, y: 8))
        icon.addCurve(to: CGPoint(x: 19, y: 4.5), controlPoint1: CGPoint(x: 17.43, y: 8), controlPoint2: CGPoint(x: 19, y: 6.43))
        icon.addCurve(to: CGPoint(x: 15.5, y: 1), controlPoint1: CGPoint(x: 19, y: 2.57), controlPoint2: CGPoint(x: 17.43, y: 1))
        icon.close()
        context.saveGState()
        context.translateBy(x: 0, y: 4)
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawBorderStyleBezel(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 20, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 20, y: resizedFrame.height / 16)

        /// Icon Shadow
        let iconShadow = UIBezierPath()
        iconShadow.move(to: CGPoint(x: 14, y: 0))
        iconShadow.addLine(to: CGPoint(x: 14, y: 10))
        iconShadow.addLine(to: CGPoint(x: 0, y: 10))
        iconShadow.addLine(to: CGPoint.zero)
        iconShadow.addLine(to: CGPoint(x: 14, y: 0))
        iconShadow.close()
        iconShadow.move(to: CGPoint(x: 13, y: 1))
        iconShadow.addLine(to: CGPoint(x: 1, y: 1))
        iconShadow.addLine(to: CGPoint(x: 1, y: 9))
        iconShadow.addLine(to: CGPoint(x: 13, y: 9))
        iconShadow.addLine(to: CGPoint(x: 13, y: 1))
        iconShadow.close()
        context.saveGState()
        context.setAlpha(0.5)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        do {
            context.translateBy(x: 3, y: 4)
            UIColor.black.setFill()
            iconShadow.fill()
        }
        context.endTransparencyLayer()
        context.restoreGState()

        /// Icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 14, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 10))
        icon.addLine(to: CGPoint(x: 0, y: 10))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 14, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 9))
        icon.addLine(to: CGPoint(x: 13, y: 9))
        icon.addLine(to: CGPoint(x: 13, y: 1))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 3)
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawBorderStyleLine(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 20, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 20, y: resizedFrame.height / 16)

        /// Icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 14, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 9))
        icon.addLine(to: CGPoint(x: 0, y: 9))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 14, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 8))
        icon.addLine(to: CGPoint(x: 13, y: 8))
        icon.addLine(to: CGPoint(x: 13, y: 1))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 3)
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawBorderStyleNone(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 20, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 20, y: resizedFrame.height / 16)

        /// Icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 3, y: 8))
        icon.addLine(to: CGPoint(x: 3, y: 9))
        icon.addLine(to: CGPoint(x: 2, y: 9))
        icon.addLine(to: CGPoint(x: 2, y: 8))
        icon.addLine(to: CGPoint(x: 3, y: 8))
        icon.close()
        icon.move(to: CGPoint(x: 5, y: 8))
        icon.addLine(to: CGPoint(x: 5, y: 9))
        icon.addLine(to: CGPoint(x: 4, y: 9))
        icon.addLine(to: CGPoint(x: 4, y: 8))
        icon.addLine(to: CGPoint(x: 5, y: 8))
        icon.close()
        icon.move(to: CGPoint(x: 7, y: 8))
        icon.addLine(to: CGPoint(x: 7, y: 9))
        icon.addLine(to: CGPoint(x: 6, y: 9))
        icon.addLine(to: CGPoint(x: 6, y: 8))
        icon.addLine(to: CGPoint(x: 7, y: 8))
        icon.close()
        icon.move(to: CGPoint(x: 9, y: 8))
        icon.addLine(to: CGPoint(x: 9, y: 9))
        icon.addLine(to: CGPoint(x: 8, y: 9))
        icon.addLine(to: CGPoint(x: 8, y: 8))
        icon.addLine(to: CGPoint(x: 9, y: 8))
        icon.close()
        icon.move(to: CGPoint(x: 11, y: 8))
        icon.addLine(to: CGPoint(x: 11, y: 9))
        icon.addLine(to: CGPoint(x: 10, y: 9))
        icon.addLine(to: CGPoint(x: 10, y: 8))
        icon.addLine(to: CGPoint(x: 11, y: 8))
        icon.close()
        icon.move(to: CGPoint(x: 1, y: 8))
        icon.addLine(to: CGPoint(x: 1, y: 9))
        icon.addLine(to: CGPoint(x: 0, y: 9))
        icon.addLine(to: CGPoint(x: 0, y: 8))
        icon.addLine(to: CGPoint(x: 1, y: 8))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 8))
        icon.addLine(to: CGPoint(x: 13, y: 9))
        icon.addLine(to: CGPoint(x: 12, y: 9))
        icon.addLine(to: CGPoint(x: 12, y: 8))
        icon.addLine(to: CGPoint(x: 13, y: 8))
        icon.close()
        icon.move(to: CGPoint(x: 1, y: 6))
        icon.addLine(to: CGPoint(x: 1, y: 7))
        icon.addLine(to: CGPoint(x: 0, y: 7))
        icon.addLine(to: CGPoint(x: 0, y: 6))
        icon.addLine(to: CGPoint(x: 1, y: 6))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 6))
        icon.addLine(to: CGPoint(x: 13, y: 7))
        icon.addLine(to: CGPoint(x: 12, y: 7))
        icon.addLine(to: CGPoint(x: 12, y: 6))
        icon.addLine(to: CGPoint(x: 13, y: 6))
        icon.close()
        icon.move(to: CGPoint(x: 1, y: 4))
        icon.addLine(to: CGPoint(x: 1, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 4))
        icon.addLine(to: CGPoint(x: 1, y: 4))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 4))
        icon.addLine(to: CGPoint(x: 13, y: 5))
        icon.addLine(to: CGPoint(x: 12, y: 5))
        icon.addLine(to: CGPoint(x: 12, y: 4))
        icon.addLine(to: CGPoint(x: 13, y: 4))
        icon.close()
        icon.move(to: CGPoint(x: 1, y: 2))
        icon.addLine(to: CGPoint(x: 1, y: 3))
        icon.addLine(to: CGPoint(x: 0, y: 3))
        icon.addLine(to: CGPoint(x: 0, y: 2))
        icon.addLine(to: CGPoint(x: 1, y: 2))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 2))
        icon.addLine(to: CGPoint(x: 13, y: 3))
        icon.addLine(to: CGPoint(x: 12, y: 3))
        icon.addLine(to: CGPoint(x: 12, y: 2))
        icon.addLine(to: CGPoint(x: 13, y: 2))
        icon.close()
        icon.move(to: CGPoint(x: 1, y: 0))
        icon.addLine(to: CGPoint(x: 1, y: 1))
        icon.addLine(to: CGPoint(x: 0, y: 1))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 1, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 3, y: 0))
        icon.addLine(to: CGPoint(x: 3, y: 1))
        icon.addLine(to: CGPoint(x: 2, y: 1))
        icon.addLine(to: CGPoint(x: 2, y: 0))
        icon.addLine(to: CGPoint(x: 3, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 5, y: 0))
        icon.addLine(to: CGPoint(x: 5, y: 1))
        icon.addLine(to: CGPoint(x: 4, y: 1))
        icon.addLine(to: CGPoint(x: 4, y: 0))
        icon.addLine(to: CGPoint(x: 5, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 7, y: 0))
        icon.addLine(to: CGPoint(x: 7, y: 1))
        icon.addLine(to: CGPoint(x: 6, y: 1))
        icon.addLine(to: CGPoint(x: 6, y: 0))
        icon.addLine(to: CGPoint(x: 7, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 9, y: 0))
        icon.addLine(to: CGPoint(x: 9, y: 1))
        icon.addLine(to: CGPoint(x: 8, y: 1))
        icon.addLine(to: CGPoint(x: 8, y: 0))
        icon.addLine(to: CGPoint(x: 9, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 11, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 1))
        icon.addLine(to: CGPoint(x: 10, y: 1))
        icon.addLine(to: CGPoint(x: 10, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 0))
        icon.addLine(to: CGPoint(x: 13, y: 1))
        icon.addLine(to: CGPoint(x: 12, y: 1))
        icon.addLine(to: CGPoint(x: 12, y: 0))
        icon.addLine(to: CGPoint(x: 13, y: 0))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 3)
        icon.usesEvenOddFillRule = true
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawTextAlignmentNatural(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 4, y: 0))
        icon.addLine(to: CGPoint(x: 4, y: 1))
        icon.addLine(to: CGPoint(x: 0, y: 1))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 4, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 9, y: 0))
        icon.addLine(to: CGPoint(x: 9, y: 1))
        icon.addLine(to: CGPoint(x: 5, y: 1))
        icon.addLine(to: CGPoint(x: 5, y: 0))
        icon.addLine(to: CGPoint(x: 9, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 1))
        icon.addLine(to: CGPoint(x: 10, y: 1))
        icon.addLine(to: CGPoint(x: 10, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 0))
        icon.close()
        context.saveGState()
        context.translateBy(x: 1, y: 7)
        icon.usesEvenOddFillRule = true
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawTextAlignmentJustified(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 14, y: 6))
        icon.addLine(to: CGPoint(x: 14, y: 7))
        icon.addLine(to: CGPoint(x: 0, y: 7))
        icon.addLine(to: CGPoint(x: 0, y: 6))
        icon.addLine(to: CGPoint(x: 14, y: 6))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 4))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 2))
        icon.addLine(to: CGPoint(x: 14, y: 3))
        icon.addLine(to: CGPoint(x: 0, y: 3))
        icon.addLine(to: CGPoint(x: 0, y: 2))
        icon.addLine(to: CGPoint(x: 14, y: 2))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 1))
        icon.addLine(to: CGPoint(x: 0, y: 1))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 14, y: 0))
        icon.close()
        context.saveGState()
        context.translateBy(x: 1, y: 4)
        icon.usesEvenOddFillRule = true
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawTextAlignmentRight(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 14, y: 6))
        icon.addLine(to: CGPoint(x: 14, y: 7))
        icon.addLine(to: CGPoint(x: 2, y: 7))
        icon.addLine(to: CGPoint(x: 2, y: 6))
        icon.addLine(to: CGPoint(x: 14, y: 6))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 4))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 2))
        icon.addLine(to: CGPoint(x: 14, y: 3))
        icon.addLine(to: CGPoint(x: 3, y: 3))
        icon.addLine(to: CGPoint(x: 3, y: 2))
        icon.addLine(to: CGPoint(x: 14, y: 2))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 1))
        icon.addLine(to: CGPoint(x: 0, y: 1))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 14, y: 0))
        icon.close()
        context.saveGState()
        context.translateBy(x: 1, y: 4)
        icon.usesEvenOddFillRule = true
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawTextAlignmentCenter(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 13, y: 6))
        icon.addLine(to: CGPoint(x: 13, y: 7))
        icon.addLine(to: CGPoint(x: 1, y: 7))
        icon.addLine(to: CGPoint(x: 1, y: 6))
        icon.addLine(to: CGPoint(x: 13, y: 6))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 4))
        icon.close()
        icon.move(to: CGPoint(x: 12, y: 2))
        icon.addLine(to: CGPoint(x: 12, y: 3))
        icon.addLine(to: CGPoint(x: 2, y: 3))
        icon.addLine(to: CGPoint(x: 2, y: 2))
        icon.addLine(to: CGPoint(x: 12, y: 2))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 1))
        icon.addLine(to: CGPoint(x: 0, y: 1))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 14, y: 0))
        icon.close()
        context.saveGState()
        context.translateBy(x: 1, y: 4)
        icon.usesEvenOddFillRule = true
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawAppearanceDark(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// Ultralight-S
        do {
            context.saveGState()

            /// Shape
            let shape = UIBezierPath()
            shape.move(to: CGPoint(x: 7.87, y: 1.35))
            shape.addCurve(to: CGPoint(x: 8.53, y: 0.68), controlPoint1: CGPoint(x: 8.23, y: 1.35), controlPoint2: CGPoint(x: 8.53, y: 1.05))
            shape.addCurve(to: CGPoint(x: 7.87, y: 0), controlPoint1: CGPoint(x: 8.53, y: 0.31), controlPoint2: CGPoint(x: 8.23, y: 0))
            shape.addCurve(to: CGPoint(x: 7.19, y: 0.68), controlPoint1: CGPoint(x: 7.5, y: 0), controlPoint2: CGPoint(x: 7.19, y: 0.31))
            shape.addCurve(to: CGPoint(x: 7.87, y: 1.35), controlPoint1: CGPoint(x: 7.19, y: 1.05), controlPoint2: CGPoint(x: 7.5, y: 1.35))
            shape.close()
            shape.move(to: CGPoint(x: 12.47, y: 3.26))
            shape.addCurve(to: CGPoint(x: 13.42, y: 3.26), controlPoint1: CGPoint(x: 12.73, y: 3.52), controlPoint2: CGPoint(x: 13.17, y: 3.52))
            shape.addCurve(to: CGPoint(x: 13.42, y: 2.3), controlPoint1: CGPoint(x: 13.68, y: 3), controlPoint2: CGPoint(x: 13.68, y: 2.57))
            shape.addCurve(to: CGPoint(x: 12.47, y: 2.3), controlPoint1: CGPoint(x: 13.17, y: 2.04), controlPoint2: CGPoint(x: 12.73, y: 2.04))
            shape.addCurve(to: CGPoint(x: 12.47, y: 3.26), controlPoint1: CGPoint(x: 12.2, y: 2.57), controlPoint2: CGPoint(x: 12.2, y: 3))
            shape.close()
            shape.move(to: CGPoint(x: 2.3, y: 3.26))
            shape.addCurve(to: CGPoint(x: 3.25, y: 3.26), controlPoint1: CGPoint(x: 2.55, y: 3.52), controlPoint2: CGPoint(x: 3, y: 3.52))
            shape.addCurve(to: CGPoint(x: 3.25, y: 2.3), controlPoint1: CGPoint(x: 3.52, y: 3), controlPoint2: CGPoint(x: 3.52, y: 2.57))
            shape.addCurve(to: CGPoint(x: 2.3, y: 2.3), controlPoint1: CGPoint(x: 3, y: 2.04), controlPoint2: CGPoint(x: 2.55, y: 2.04))
            shape.addCurve(to: CGPoint(x: 2.3, y: 3.26), controlPoint1: CGPoint(x: 2.04, y: 2.57), controlPoint2: CGPoint(x: 2.04, y: 3))
            shape.close()
            shape.move(to: CGPoint(x: 7.87, y: 11.69))
            shape.addCurve(to: CGPoint(x: 11.69, y: 7.87), controlPoint1: CGPoint(x: 9.96, y: 11.69), controlPoint2: CGPoint(x: 11.69, y: 9.96))
            shape.addCurve(to: CGPoint(x: 7.87, y: 4.04), controlPoint1: CGPoint(x: 11.69, y: 5.77), controlPoint2: CGPoint(x: 9.96, y: 4.04))
            shape.addCurve(to: CGPoint(x: 4.03, y: 7.87), controlPoint1: CGPoint(x: 5.76, y: 4.04), controlPoint2: CGPoint(x: 4.03, y: 5.77))
            shape.addCurve(to: CGPoint(x: 7.87, y: 11.69), controlPoint1: CGPoint(x: 4.03, y: 9.96), controlPoint2: CGPoint(x: 5.76, y: 11.69))
            shape.close()
            shape.move(to: CGPoint(x: 7.87, y: 11.22))
            shape.addCurve(to: CGPoint(x: 4.51, y: 7.87), controlPoint1: CGPoint(x: 6.03, y: 11.22), controlPoint2: CGPoint(x: 4.51, y: 9.7))
            shape.addCurve(to: CGPoint(x: 7.87, y: 4.51), controlPoint1: CGPoint(x: 4.51, y: 6.03), controlPoint2: CGPoint(x: 6.03, y: 4.51))
            shape.addCurve(to: CGPoint(x: 11.21, y: 7.87), controlPoint1: CGPoint(x: 9.69, y: 4.51), controlPoint2: CGPoint(x: 11.21, y: 6.03))
            shape.addCurve(to: CGPoint(x: 7.87, y: 11.22), controlPoint1: CGPoint(x: 11.21, y: 9.7), controlPoint2: CGPoint(x: 9.69, y: 11.22))
            shape.close()
            shape.move(to: CGPoint(x: 0.68, y: 8.54))
            shape.addCurve(to: CGPoint(x: 1.35, y: 7.87), controlPoint1: CGPoint(x: 1.05, y: 8.54), controlPoint2: CGPoint(x: 1.35, y: 8.23))
            shape.addCurve(to: CGPoint(x: 0.68, y: 7.19), controlPoint1: CGPoint(x: 1.35, y: 7.5), controlPoint2: CGPoint(x: 1.05, y: 7.19))
            shape.addCurve(to: CGPoint(x: 0, y: 7.87), controlPoint1: CGPoint(x: 0.31, y: 7.19), controlPoint2: CGPoint(x: 0, y: 7.5))
            shape.addCurve(to: CGPoint(x: 0.68, y: 8.54), controlPoint1: CGPoint(x: 0, y: 8.23), controlPoint2: CGPoint(x: 0.31, y: 8.54))
            shape.close()
            shape.move(to: CGPoint(x: 15.04, y: 8.54))
            shape.addCurve(to: CGPoint(x: 15.72, y: 7.87), controlPoint1: CGPoint(x: 15.41, y: 8.54), controlPoint2: CGPoint(x: 15.72, y: 8.23))
            shape.addCurve(to: CGPoint(x: 15.04, y: 7.2), controlPoint1: CGPoint(x: 15.72, y: 7.5), controlPoint2: CGPoint(x: 15.41, y: 7.2))
            shape.addCurve(to: CGPoint(x: 14.38, y: 7.87), controlPoint1: CGPoint(x: 14.67, y: 7.2), controlPoint2: CGPoint(x: 14.38, y: 7.5))
            shape.addCurve(to: CGPoint(x: 15.04, y: 8.54), controlPoint1: CGPoint(x: 14.38, y: 8.23), controlPoint2: CGPoint(x: 14.67, y: 8.54))
            shape.close()
            shape.move(to: CGPoint(x: 2.3, y: 13.43))
            shape.addCurve(to: CGPoint(x: 3.25, y: 13.43), controlPoint1: CGPoint(x: 2.55, y: 13.68), controlPoint2: CGPoint(x: 3, y: 13.68))
            shape.addCurve(to: CGPoint(x: 3.25, y: 12.47), controlPoint1: CGPoint(x: 3.52, y: 13.17), controlPoint2: CGPoint(x: 3.52, y: 12.73))
            shape.addCurve(to: CGPoint(x: 2.3, y: 12.47), controlPoint1: CGPoint(x: 3, y: 12.21), controlPoint2: CGPoint(x: 2.55, y: 12.21))
            shape.addCurve(to: CGPoint(x: 2.3, y: 13.43), controlPoint1: CGPoint(x: 2.04, y: 12.73), controlPoint2: CGPoint(x: 2.04, y: 13.17))
            shape.close()
            shape.move(to: CGPoint(x: 12.47, y: 13.43))
            shape.addCurve(to: CGPoint(x: 13.42, y: 13.43), controlPoint1: CGPoint(x: 12.72, y: 13.69), controlPoint2: CGPoint(x: 13.15, y: 13.69))
            shape.addCurve(to: CGPoint(x: 13.42, y: 12.48), controlPoint1: CGPoint(x: 13.68, y: 13.17), controlPoint2: CGPoint(x: 13.68, y: 12.73))
            shape.addCurve(to: CGPoint(x: 12.47, y: 12.48), controlPoint1: CGPoint(x: 13.15, y: 12.21), controlPoint2: CGPoint(x: 12.72, y: 12.21))
            shape.addCurve(to: CGPoint(x: 12.47, y: 13.43), controlPoint1: CGPoint(x: 12.2, y: 12.73), controlPoint2: CGPoint(x: 12.2, y: 13.17))
            shape.close()
            shape.move(to: CGPoint(x: 7.87, y: 15.73))
            shape.addCurve(to: CGPoint(x: 8.53, y: 15.05), controlPoint1: CGPoint(x: 8.23, y: 15.73), controlPoint2: CGPoint(x: 8.53, y: 15.42))
            shape.addCurve(to: CGPoint(x: 7.87, y: 14.38), controlPoint1: CGPoint(x: 8.53, y: 14.69), controlPoint2: CGPoint(x: 8.23, y: 14.38))
            shape.addCurve(to: CGPoint(x: 7.19, y: 15.05), controlPoint1: CGPoint(x: 7.5, y: 14.38), controlPoint2: CGPoint(x: 7.19, y: 14.69))
            shape.addCurve(to: CGPoint(x: 7.87, y: 15.73), controlPoint1: CGPoint(x: 7.19, y: 15.42), controlPoint2: CGPoint(x: 7.5, y: 15.73))
            shape.close()
            context.saveGState()
            context.translateBy(x: 0.18, y: 0.1)
            UIColor.black.setFill()
            shape.fill()
            context.restoreGState()

            context.restoreGState()
        }

        context.restoreGState()
    }

    class func drawAppearanceMedium(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// Shape
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: 8, y: 2.04))
        shape.addCurve(to: CGPoint(x: 9.03, y: 1.02), controlPoint1: CGPoint(x: 8.56, y: 2.04), controlPoint2: CGPoint(x: 9.03, y: 1.58))
        shape.addCurve(to: CGPoint(x: 8, y: 0), controlPoint1: CGPoint(x: 9.03, y: 0.46), controlPoint2: CGPoint(x: 8.57, y: 0))
        shape.addCurve(to: CGPoint(x: 6.98, y: 1.02), controlPoint1: CGPoint(x: 7.43, y: 0), controlPoint2: CGPoint(x: 6.98, y: 0.45))
        shape.addCurve(to: CGPoint(x: 8, y: 2.04), controlPoint1: CGPoint(x: 6.98, y: 1.57), controlPoint2: CGPoint(x: 7.45, y: 2.04))
        shape.close()
        shape.move(to: CGPoint(x: 12.22, y: 3.78))
        shape.addCurve(to: CGPoint(x: 13.66, y: 3.78), controlPoint1: CGPoint(x: 12.61, y: 4.18), controlPoint2: CGPoint(x: 13.26, y: 4.18))
        shape.addCurve(to: CGPoint(x: 13.66, y: 2.34), controlPoint1: CGPoint(x: 14.07, y: 3.38), controlPoint2: CGPoint(x: 14.07, y: 2.74))
        shape.addCurve(to: CGPoint(x: 12.22, y: 2.34), controlPoint1: CGPoint(x: 13.25, y: 1.93), controlPoint2: CGPoint(x: 12.62, y: 1.93))
        shape.addCurve(to: CGPoint(x: 12.22, y: 3.78), controlPoint1: CGPoint(x: 11.82, y: 2.74), controlPoint2: CGPoint(x: 11.82, y: 3.39))
        shape.close()
        shape.move(to: CGPoint(x: 2.34, y: 3.79))
        shape.addCurve(to: CGPoint(x: 3.78, y: 3.79), controlPoint1: CGPoint(x: 2.73, y: 4.19), controlPoint2: CGPoint(x: 3.38, y: 4.19))
        shape.addCurve(to: CGPoint(x: 3.78, y: 2.35), controlPoint1: CGPoint(x: 4.2, y: 3.38), controlPoint2: CGPoint(x: 4.2, y: 2.76))
        shape.addCurve(to: CGPoint(x: 2.34, y: 2.35), controlPoint1: CGPoint(x: 3.38, y: 1.94), controlPoint2: CGPoint(x: 2.74, y: 1.94))
        shape.addCurve(to: CGPoint(x: 2.34, y: 3.79), controlPoint1: CGPoint(x: 1.94, y: 2.75), controlPoint2: CGPoint(x: 1.94, y: 3.39))
        shape.close()
        shape.move(to: CGPoint(x: 8, y: 12.15))
        shape.addCurve(to: CGPoint(x: 12.14, y: 8.01), controlPoint1: CGPoint(x: 10.27, y: 12.15), controlPoint2: CGPoint(x: 12.14, y: 10.28))
        shape.addCurve(to: CGPoint(x: 8, y: 3.88), controlPoint1: CGPoint(x: 12.14, y: 5.75), controlPoint2: CGPoint(x: 10.27, y: 3.88))
        shape.addCurve(to: CGPoint(x: 3.87, y: 8.01), controlPoint1: CGPoint(x: 5.74, y: 3.88), controlPoint2: CGPoint(x: 3.87, y: 5.75))
        shape.addCurve(to: CGPoint(x: 8, y: 12.15), controlPoint1: CGPoint(x: 3.87, y: 10.28), controlPoint2: CGPoint(x: 5.74, y: 12.15))
        shape.close()
        shape.move(to: CGPoint(x: 8, y: 10.56))
        shape.addCurve(to: CGPoint(x: 5.46, y: 8.01), controlPoint1: CGPoint(x: 6.61, y: 10.56), controlPoint2: CGPoint(x: 5.46, y: 9.4))
        shape.addCurve(to: CGPoint(x: 8, y: 5.47), controlPoint1: CGPoint(x: 5.46, y: 6.63), controlPoint2: CGPoint(x: 6.61, y: 5.47))
        shape.addCurve(to: CGPoint(x: 10.55, y: 8.01), controlPoint1: CGPoint(x: 9.39, y: 5.47), controlPoint2: CGPoint(x: 10.55, y: 6.63))
        shape.addCurve(to: CGPoint(x: 8, y: 10.56), controlPoint1: CGPoint(x: 10.55, y: 9.4), controlPoint2: CGPoint(x: 9.39, y: 10.56))
        shape.close()
        shape.move(to: CGPoint(x: 1.02, y: 9.03))
        shape.addCurve(to: CGPoint(x: 2.04, y: 8), controlPoint1: CGPoint(x: 1.58, y: 9.03), controlPoint2: CGPoint(x: 2.04, y: 8.56))
        shape.addCurve(to: CGPoint(x: 1.02, y: 6.98), controlPoint1: CGPoint(x: 2.04, y: 7.44), controlPoint2: CGPoint(x: 1.6, y: 6.98))
        shape.addCurve(to: CGPoint(x: 0, y: 8), controlPoint1: CGPoint(x: 0.46, y: 6.98), controlPoint2: CGPoint(x: 0, y: 7.44))
        shape.addCurve(to: CGPoint(x: 1.02, y: 9.03), controlPoint1: CGPoint(x: 0, y: 8.56), controlPoint2: CGPoint(x: 0.47, y: 9.03))
        shape.close()
        shape.move(to: CGPoint(x: 14.98, y: 9.09))
        shape.addCurve(to: CGPoint(x: 16, y: 8.06), controlPoint1: CGPoint(x: 15.55, y: 9.09), controlPoint2: CGPoint(x: 16, y: 8.63))
        shape.addCurve(to: CGPoint(x: 14.98, y: 7.04), controlPoint1: CGPoint(x: 16, y: 7.51), controlPoint2: CGPoint(x: 15.53, y: 7.04))
        shape.addCurve(to: CGPoint(x: 13.96, y: 8.06), controlPoint1: CGPoint(x: 14.42, y: 7.04), controlPoint2: CGPoint(x: 13.96, y: 7.5))
        shape.addCurve(to: CGPoint(x: 14.98, y: 9.09), controlPoint1: CGPoint(x: 13.96, y: 8.62), controlPoint2: CGPoint(x: 14.42, y: 9.09))
        shape.close()
        shape.move(to: CGPoint(x: 2.35, y: 13.66))
        shape.addCurve(to: CGPoint(x: 3.79, y: 13.66), controlPoint1: CGPoint(x: 2.75, y: 14.07), controlPoint2: CGPoint(x: 3.39, y: 14.07))
        shape.addCurve(to: CGPoint(x: 3.79, y: 12.21), controlPoint1: CGPoint(x: 4.19, y: 13.26), controlPoint2: CGPoint(x: 4.19, y: 12.61))
        shape.addCurve(to: CGPoint(x: 2.35, y: 12.21), controlPoint1: CGPoint(x: 3.39, y: 11.82), controlPoint2: CGPoint(x: 2.74, y: 11.82))
        shape.addCurve(to: CGPoint(x: 2.35, y: 13.66), controlPoint1: CGPoint(x: 1.93, y: 12.62), controlPoint2: CGPoint(x: 1.93, y: 13.25))
        shape.close()
        shape.move(to: CGPoint(x: 12.17, y: 13.7))
        shape.addCurve(to: CGPoint(x: 13.62, y: 13.7), controlPoint1: CGPoint(x: 12.58, y: 14.11), controlPoint2: CGPoint(x: 13.2, y: 14.11))
        shape.addCurve(to: CGPoint(x: 13.62, y: 12.26), controlPoint1: CGPoint(x: 14.02, y: 13.31), controlPoint2: CGPoint(x: 14.02, y: 12.66))
        shape.addCurve(to: CGPoint(x: 12.17, y: 12.26), controlPoint1: CGPoint(x: 13.21, y: 11.85), controlPoint2: CGPoint(x: 12.58, y: 11.85))
        shape.addCurve(to: CGPoint(x: 12.17, y: 13.7), controlPoint1: CGPoint(x: 11.77, y: 12.66), controlPoint2: CGPoint(x: 11.77, y: 13.3))
        shape.close()
        shape.move(to: CGPoint(x: 8, y: 16))
        shape.addCurve(to: CGPoint(x: 9.03, y: 14.98), controlPoint1: CGPoint(x: 8.57, y: 16), controlPoint2: CGPoint(x: 9.03, y: 15.54))
        shape.addCurve(to: CGPoint(x: 8, y: 13.96), controlPoint1: CGPoint(x: 9.03, y: 14.42), controlPoint2: CGPoint(x: 8.56, y: 13.96))
        shape.addCurve(to: CGPoint(x: 6.98, y: 14.98), controlPoint1: CGPoint(x: 7.45, y: 13.96), controlPoint2: CGPoint(x: 6.98, y: 14.42))
        shape.addCurve(to: CGPoint(x: 8, y: 16), controlPoint1: CGPoint(x: 6.98, y: 15.54), controlPoint2: CGPoint(x: 7.43, y: 16))
        shape.close()
        context.saveGState()
        UIColor.black.setFill()
        shape.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawSliderHorizontal(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)

        /// Shape
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: 12.14, y: 4.49))
        shape.addCurve(to: CGPoint(x: 14.25, y: 3.13), controlPoint1: CGPoint(x: 13.08, y: 4.49), controlPoint2: CGPoint(x: 13.9, y: 3.93))
        shape.addLine(to: CGPoint(x: 17.13, y: 3.13))
        shape.addCurve(to: CGPoint(x: 18, y: 2.24), controlPoint1: CGPoint(x: 17.6, y: 3.13), controlPoint2: CGPoint(x: 18, y: 2.74))
        shape.addCurve(to: CGPoint(x: 17.13, y: 1.36), controlPoint1: CGPoint(x: 18, y: 1.74), controlPoint2: CGPoint(x: 17.6, y: 1.36))
        shape.addLine(to: CGPoint(x: 14.25, y: 1.36))
        shape.addCurve(to: CGPoint(x: 12.14, y: 0), controlPoint1: CGPoint(x: 13.9, y: 0.56), controlPoint2: CGPoint(x: 13.08, y: 0))
        shape.addCurve(to: CGPoint(x: 10.03, y: 1.36), controlPoint1: CGPoint(x: 11.19, y: 0), controlPoint2: CGPoint(x: 10.38, y: 0.56))
        shape.addLine(to: CGPoint(x: 0.9, y: 1.36))
        shape.addCurve(to: CGPoint(x: 0, y: 2.24), controlPoint1: CGPoint(x: 0.4, y: 1.36), controlPoint2: CGPoint(x: 0, y: 1.76))
        shape.addCurve(to: CGPoint(x: 0.9, y: 3.13), controlPoint1: CGPoint(x: 0, y: 2.72), controlPoint2: CGPoint(x: 0.4, y: 3.13))
        shape.addLine(to: CGPoint(x: 10.03, y: 3.13))
        shape.addCurve(to: CGPoint(x: 12.14, y: 4.49), controlPoint1: CGPoint(x: 10.39, y: 3.93), controlPoint2: CGPoint(x: 11.19, y: 4.49))
        shape.close()
        shape.move(to: CGPoint(x: 12.14, y: 3.25))
        shape.addCurve(to: CGPoint(x: 11.11, y: 2.24), controlPoint1: CGPoint(x: 11.56, y: 3.25), controlPoint2: CGPoint(x: 11.11, y: 2.81))
        shape.addCurve(to: CGPoint(x: 12.14, y: 1.23), controlPoint1: CGPoint(x: 11.11, y: 1.67), controlPoint2: CGPoint(x: 11.56, y: 1.23))
        shape.addCurve(to: CGPoint(x: 13.18, y: 2.24), controlPoint1: CGPoint(x: 12.73, y: 1.23), controlPoint2: CGPoint(x: 13.18, y: 1.67))
        shape.addCurve(to: CGPoint(x: 12.14, y: 3.25), controlPoint1: CGPoint(x: 13.18, y: 2.81), controlPoint2: CGPoint(x: 12.73, y: 3.25))
        shape.close()
        shape.move(to: CGPoint(x: 0.87, y: 6.61))
        shape.addCurve(to: CGPoint(x: 0, y: 7.51), controlPoint1: CGPoint(x: 0.4, y: 6.61), controlPoint2: CGPoint(x: 0, y: 7.01))
        shape.addCurve(to: CGPoint(x: 0.87, y: 8.39), controlPoint1: CGPoint(x: 0, y: 7.99), controlPoint2: CGPoint(x: 0.4, y: 8.39))
        shape.addLine(to: CGPoint(x: 3.78, y: 8.39))
        shape.addCurve(to: CGPoint(x: 5.9, y: 9.75), controlPoint1: CGPoint(x: 4.14, y: 9.19), controlPoint2: CGPoint(x: 4.95, y: 9.75))
        shape.addCurve(to: CGPoint(x: 8.01, y: 8.39), controlPoint1: CGPoint(x: 6.84, y: 9.75), controlPoint2: CGPoint(x: 7.65, y: 9.19))
        shape.addLine(to: CGPoint(x: 17.1, y: 8.39))
        shape.addCurve(to: CGPoint(x: 18, y: 7.51), controlPoint1: CGPoint(x: 17.6, y: 8.39), controlPoint2: CGPoint(x: 18, y: 7.99))
        shape.addCurve(to: CGPoint(x: 17.1, y: 6.61), controlPoint1: CGPoint(x: 18, y: 7.01), controlPoint2: CGPoint(x: 17.6, y: 6.61))
        shape.addLine(to: CGPoint(x: 8.01, y: 6.61))
        shape.addCurve(to: CGPoint(x: 5.9, y: 5.25), controlPoint1: CGPoint(x: 7.65, y: 5.81), controlPoint2: CGPoint(x: 6.84, y: 5.25))
        shape.addCurve(to: CGPoint(x: 3.78, y: 6.61), controlPoint1: CGPoint(x: 4.95, y: 5.25), controlPoint2: CGPoint(x: 4.14, y: 5.81))
        shape.addLine(to: CGPoint(x: 0.87, y: 6.61))
        shape.close()
        shape.move(to: CGPoint(x: 5.9, y: 8.52))
        shape.addCurve(to: CGPoint(x: 4.86, y: 7.51), controlPoint1: CGPoint(x: 5.32, y: 8.52), controlPoint2: CGPoint(x: 4.86, y: 8.07))
        shape.addCurve(to: CGPoint(x: 5.9, y: 6.48), controlPoint1: CGPoint(x: 4.86, y: 6.92), controlPoint2: CGPoint(x: 5.32, y: 6.48))
        shape.addCurve(to: CGPoint(x: 6.94, y: 7.51), controlPoint1: CGPoint(x: 6.49, y: 6.48), controlPoint2: CGPoint(x: 6.94, y: 6.92))
        shape.addCurve(to: CGPoint(x: 5.9, y: 8.52), controlPoint1: CGPoint(x: 6.94, y: 8.07), controlPoint2: CGPoint(x: 6.49, y: 8.52))
        shape.close()
        shape.move(to: CGPoint(x: 12.14, y: 15))
        shape.addCurve(to: CGPoint(x: 14.25, y: 13.64), controlPoint1: CGPoint(x: 13.08, y: 15), controlPoint2: CGPoint(x: 13.9, y: 14.44))
        shape.addLine(to: CGPoint(x: 17.13, y: 13.64))
        shape.addCurve(to: CGPoint(x: 18, y: 12.76), controlPoint1: CGPoint(x: 17.6, y: 13.64), controlPoint2: CGPoint(x: 18, y: 13.24))
        shape.addCurve(to: CGPoint(x: 17.13, y: 11.87), controlPoint1: CGPoint(x: 18, y: 12.26), controlPoint2: CGPoint(x: 17.6, y: 11.87))
        shape.addLine(to: CGPoint(x: 14.25, y: 11.87))
        shape.addCurve(to: CGPoint(x: 12.14, y: 10.51), controlPoint1: CGPoint(x: 13.9, y: 11.07), controlPoint2: CGPoint(x: 13.08, y: 10.51))
        shape.addCurve(to: CGPoint(x: 10.03, y: 11.87), controlPoint1: CGPoint(x: 11.19, y: 10.51), controlPoint2: CGPoint(x: 10.39, y: 11.07))
        shape.addLine(to: CGPoint(x: 0.9, y: 11.87))
        shape.addCurve(to: CGPoint(x: 0, y: 12.76), controlPoint1: CGPoint(x: 0.4, y: 11.87), controlPoint2: CGPoint(x: 0, y: 12.26))
        shape.addCurve(to: CGPoint(x: 0.9, y: 13.64), controlPoint1: CGPoint(x: 0, y: 13.24), controlPoint2: CGPoint(x: 0.4, y: 13.64))
        shape.addLine(to: CGPoint(x: 10.03, y: 13.64))
        shape.addCurve(to: CGPoint(x: 12.14, y: 15), controlPoint1: CGPoint(x: 10.38, y: 14.44), controlPoint2: CGPoint(x: 11.19, y: 15))
        shape.close()
        shape.move(to: CGPoint(x: 12.14, y: 13.77))
        shape.addCurve(to: CGPoint(x: 11.11, y: 12.76), controlPoint1: CGPoint(x: 11.56, y: 13.77), controlPoint2: CGPoint(x: 11.11, y: 13.32))
        shape.addCurve(to: CGPoint(x: 12.14, y: 11.75), controlPoint1: CGPoint(x: 11.11, y: 12.18), controlPoint2: CGPoint(x: 11.56, y: 11.75))
        shape.addCurve(to: CGPoint(x: 13.18, y: 12.76), controlPoint1: CGPoint(x: 12.73, y: 11.75), controlPoint2: CGPoint(x: 13.18, y: 12.18))
        shape.addCurve(to: CGPoint(x: 12.14, y: 13.77), controlPoint1: CGPoint(x: 13.18, y: 13.32), controlPoint2: CGPoint(x: 12.73, y: 13.77))
        shape.close()
        context.saveGState()
        context.translateBy(x: 3, y: 5)
        color.setFill()
        shape.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawSetSquareFill(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)

        /// SetSquare
        let setSquare = UIBezierPath()
        setSquare.move(to: CGPoint(x: 0.43, y: 0))
        setSquare.addCurve(to: CGPoint(x: 0.74, y: 0.14), controlPoint1: CGPoint(x: 0.55, y: 0), controlPoint2: CGPoint(x: 0.66, y: 0.05))
        setSquare.addLine(to: CGPoint(x: 13.9, y: 14.28))
        setSquare.addCurve(to: CGPoint(x: 13.87, y: 14.88), controlPoint1: CGPoint(x: 14.06, y: 14.45), controlPoint2: CGPoint(x: 14.05, y: 14.72))
        setSquare.addCurve(to: CGPoint(x: 13.58, y: 15), controlPoint1: CGPoint(x: 13.79, y: 14.96), controlPoint2: CGPoint(x: 13.69, y: 15))
        setSquare.addLine(to: CGPoint(x: 0.43, y: 15))
        setSquare.addCurve(to: CGPoint(x: 0, y: 14.57), controlPoint1: CGPoint(x: 0.19, y: 15), controlPoint2: CGPoint(x: 0, y: 14.81))
        setSquare.addLine(to: CGPoint(x: 0, y: 0.43))
        setSquare.addCurve(to: CGPoint(x: 0.43, y: 0), controlPoint1: CGPoint(x: 0, y: 0.19), controlPoint2: CGPoint(x: 0.19, y: 0))
        setSquare.close()
        setSquare.move(to: CGPoint(x: 3, y: 5.99))
        setSquare.addCurve(to: CGPoint(x: 2.57, y: 6.42), controlPoint1: CGPoint(x: 2.76, y: 5.99), controlPoint2: CGPoint(x: 2.57, y: 6.19))
        setSquare.addLine(to: CGPoint(x: 2.57, y: 6.42))
        setSquare.addLine(to: CGPoint(x: 2.57, y: 11.96))
        setSquare.addCurve(to: CGPoint(x: 3, y: 12.39), controlPoint1: CGPoint(x: 2.57, y: 12.2), controlPoint2: CGPoint(x: 2.76, y: 12.39))
        setSquare.addLine(to: CGPoint(x: 3, y: 12.39))
        setSquare.addLine(to: CGPoint(x: 8.54, y: 12.39))
        setSquare.addCurve(to: CGPoint(x: 8.84, y: 12.26), controlPoint1: CGPoint(x: 8.65, y: 12.39), controlPoint2: CGPoint(x: 8.76, y: 12.34))
        setSquare.addCurve(to: CGPoint(x: 8.84, y: 11.66), controlPoint1: CGPoint(x: 9.01, y: 12.1), controlPoint2: CGPoint(x: 9.01, y: 11.82))
        setSquare.addLine(to: CGPoint(x: 8.84, y: 11.66))
        setSquare.addLine(to: CGPoint(x: 3.3, y: 6.12))
        setSquare.addCurve(to: CGPoint(x: 3, y: 5.99), controlPoint1: CGPoint(x: 3.22, y: 6.04), controlPoint2: CGPoint(x: 3.11, y: 5.99))
        setSquare.close()
        context.saveGState()
        context.translateBy(x: 5, y: 5)
        UIColor.black.setFill()
        setSquare.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawAppearanceLight(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// Shape
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: 8, y: 2.34))
        shape.addCurve(to: CGPoint(x: 9.17, y: 1.17), controlPoint1: CGPoint(x: 8.62, y: 2.34), controlPoint2: CGPoint(x: 9.17, y: 1.8))
        shape.addCurve(to: CGPoint(x: 8, y: 0), controlPoint1: CGPoint(x: 9.17, y: 0.52), controlPoint2: CGPoint(x: 8.65, y: 0))
        shape.addCurve(to: CGPoint(x: 6.83, y: 1.17), controlPoint1: CGPoint(x: 7.31, y: 0), controlPoint2: CGPoint(x: 6.83, y: 0.48))
        shape.addCurve(to: CGPoint(x: 8, y: 2.34), controlPoint1: CGPoint(x: 6.83, y: 1.78), controlPoint2: CGPoint(x: 7.4, y: 2.34))
        shape.close()
        shape.move(to: CGPoint(x: 12, y: 4))
        shape.addCurve(to: CGPoint(x: 13.66, y: 4), controlPoint1: CGPoint(x: 12.44, y: 4.44), controlPoint2: CGPoint(x: 13.22, y: 4.44))
        shape.addCurve(to: CGPoint(x: 13.66, y: 2.34), controlPoint1: CGPoint(x: 14.12, y: 3.54), controlPoint2: CGPoint(x: 14.12, y: 2.8))
        shape.addCurve(to: CGPoint(x: 12, y: 2.34), controlPoint1: CGPoint(x: 13.17, y: 1.86), controlPoint2: CGPoint(x: 12.48, y: 1.86))
        shape.addCurve(to: CGPoint(x: 12, y: 4), controlPoint1: CGPoint(x: 11.57, y: 2.77), controlPoint2: CGPoint(x: 11.57, y: 3.57))
        shape.close()
        shape.move(to: CGPoint(x: 2.33, y: 4.01))
        shape.addCurve(to: CGPoint(x: 3.99, y: 4.01), controlPoint1: CGPoint(x: 2.76, y: 4.44), controlPoint2: CGPoint(x: 3.56, y: 4.44))
        shape.addCurve(to: CGPoint(x: 3.99, y: 2.35), controlPoint1: CGPoint(x: 4.48, y: 3.52), controlPoint2: CGPoint(x: 4.48, y: 2.84))
        shape.addCurve(to: CGPoint(x: 2.33, y: 2.35), controlPoint1: CGPoint(x: 3.53, y: 1.89), controlPoint2: CGPoint(x: 2.8, y: 1.89))
        shape.addCurve(to: CGPoint(x: 2.33, y: 4.01), controlPoint1: CGPoint(x: 1.9, y: 2.79), controlPoint2: CGPoint(x: 1.9, y: 3.56))
        shape.close()
        shape.move(to: CGPoint(x: 8, y: 12.29))
        shape.addCurve(to: CGPoint(x: 12.28, y: 8.01), controlPoint1: CGPoint(x: 10.34, y: 12.29), controlPoint2: CGPoint(x: 12.28, y: 10.35))
        shape.addCurve(to: CGPoint(x: 8, y: 3.73), controlPoint1: CGPoint(x: 12.28, y: 5.67), controlPoint2: CGPoint(x: 10.34, y: 3.73))
        shape.addCurve(to: CGPoint(x: 3.72, y: 8.01), controlPoint1: CGPoint(x: 5.66, y: 3.73), controlPoint2: CGPoint(x: 3.72, y: 5.67))
        shape.addCurve(to: CGPoint(x: 8, y: 12.29), controlPoint1: CGPoint(x: 3.72, y: 10.37), controlPoint2: CGPoint(x: 5.64, y: 12.29))
        shape.close()
        shape.move(to: CGPoint(x: 14.83, y: 9.18))
        shape.addCurve(to: CGPoint(x: 16, y: 8.01), controlPoint1: CGPoint(x: 15.52, y: 9.18), controlPoint2: CGPoint(x: 16, y: 8.7))
        shape.addCurve(to: CGPoint(x: 14.83, y: 6.84), controlPoint1: CGPoint(x: 16, y: 7.4), controlPoint2: CGPoint(x: 15.43, y: 6.84))
        shape.addCurve(to: CGPoint(x: 13.66, y: 8.01), controlPoint1: CGPoint(x: 14.2, y: 6.84), controlPoint2: CGPoint(x: 13.66, y: 7.39))
        shape.addCurve(to: CGPoint(x: 14.83, y: 9.18), controlPoint1: CGPoint(x: 13.66, y: 8.66), controlPoint2: CGPoint(x: 14.18, y: 9.18))
        shape.close()
        shape.move(to: CGPoint(x: 1.17, y: 9.18))
        shape.addCurve(to: CGPoint(x: 2.34, y: 8.01), controlPoint1: CGPoint(x: 1.78, y: 9.18), controlPoint2: CGPoint(x: 2.34, y: 8.61))
        shape.addCurve(to: CGPoint(x: 1.17, y: 6.84), controlPoint1: CGPoint(x: 2.34, y: 7.32), controlPoint2: CGPoint(x: 1.86, y: 6.84))
        shape.addCurve(to: CGPoint(x: 0, y: 8.01), controlPoint1: CGPoint(x: 0.52, y: 6.84), controlPoint2: CGPoint(x: 0, y: 7.36))
        shape.addCurve(to: CGPoint(x: 1.17, y: 9.18), controlPoint1: CGPoint(x: 0, y: 8.63), controlPoint2: CGPoint(x: 0.55, y: 9.18))
        shape.close()
        shape.move(to: CGPoint(x: 11.99, y: 13.67))
        shape.addCurve(to: CGPoint(x: 13.65, y: 13.67), controlPoint1: CGPoint(x: 12.48, y: 14.15), controlPoint2: CGPoint(x: 13.16, y: 14.15))
        shape.addCurve(to: CGPoint(x: 13.65, y: 12.01), controlPoint1: CGPoint(x: 14.07, y: 13.24), controlPoint2: CGPoint(x: 14.07, y: 12.44))
        shape.addCurve(to: CGPoint(x: 11.99, y: 12.01), controlPoint1: CGPoint(x: 13.21, y: 11.56), controlPoint2: CGPoint(x: 12.44, y: 11.56))
        shape.addCurve(to: CGPoint(x: 11.99, y: 13.67), controlPoint1: CGPoint(x: 11.53, y: 12.47), controlPoint2: CGPoint(x: 11.53, y: 13.2))
        shape.close()
        shape.move(to: CGPoint(x: 2.34, y: 13.66))
        shape.addCurve(to: CGPoint(x: 4, y: 13.66), controlPoint1: CGPoint(x: 2.8, y: 14.12), controlPoint2: CGPoint(x: 3.54, y: 14.12))
        shape.addCurve(to: CGPoint(x: 4, y: 12), controlPoint1: CGPoint(x: 4.44, y: 13.22), controlPoint2: CGPoint(x: 4.44, y: 12.44))
        shape.addCurve(to: CGPoint(x: 2.34, y: 12), controlPoint1: CGPoint(x: 3.57, y: 11.57), controlPoint2: CGPoint(x: 2.77, y: 11.57))
        shape.addCurve(to: CGPoint(x: 2.34, y: 13.66), controlPoint1: CGPoint(x: 1.86, y: 12.48), controlPoint2: CGPoint(x: 1.86, y: 13.17))
        shape.close()
        shape.move(to: CGPoint(x: 8, y: 16))
        shape.addCurve(to: CGPoint(x: 9.17, y: 14.83), controlPoint1: CGPoint(x: 8.65, y: 16), controlPoint2: CGPoint(x: 9.17, y: 15.48))
        shape.addCurve(to: CGPoint(x: 8, y: 13.66), controlPoint1: CGPoint(x: 9.17, y: 14.2), controlPoint2: CGPoint(x: 8.62, y: 13.66))
        shape.addCurve(to: CGPoint(x: 6.83, y: 14.83), controlPoint1: CGPoint(x: 7.4, y: 13.66), controlPoint2: CGPoint(x: 6.83, y: 14.22))
        shape.addCurve(to: CGPoint(x: 8, y: 16), controlPoint1: CGPoint(x: 6.83, y: 15.52), controlPoint2: CGPoint(x: 7.31, y: 16))
        shape.close()
        context.saveGState()
        UIColor.black.setFill()
        shape.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawTextAlignmentLeft(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 12, y: 6))
        icon.addLine(to: CGPoint(x: 12, y: 7))
        icon.addLine(to: CGPoint(x: 0, y: 7))
        icon.addLine(to: CGPoint(x: 0, y: 6))
        icon.addLine(to: CGPoint(x: 12, y: 6))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 5))
        icon.addLine(to: CGPoint(x: 0, y: 4))
        icon.addLine(to: CGPoint(x: 14, y: 4))
        icon.close()
        icon.move(to: CGPoint(x: 11, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 3))
        icon.addLine(to: CGPoint(x: 0, y: 3))
        icon.addLine(to: CGPoint(x: 0, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 2))
        icon.close()
        icon.move(to: CGPoint(x: 14, y: 0))
        icon.addLine(to: CGPoint(x: 14, y: 1))
        icon.addLine(to: CGPoint(x: 0, y: 1))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 14, y: 0))
        icon.close()
        context.saveGState()
        context.translateBy(x: 1, y: 4)
        icon.usesEvenOddFillRule = true
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawColorGrid(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 32, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 32, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 32, y: resizedFrame.height / 16)

        /// Background Color
        UIColor.clear.setFill()
        context.fill(context.boundingBoxOfClipPath)

        /// grid
        /// pattern
        context.saveGState()
        context.setAlpha(0.2)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        do {
            /// grid
            let grid = UIBezierPath()
            grid.move(to: CGPoint.zero)
            grid.addLine(to: CGPoint(x: 8, y: 0))
            grid.addLine(to: CGPoint(x: 8, y: 8))
            grid.addLine(to: CGPoint(x: 0, y: 8))
            grid.addLine(to: CGPoint.zero)
            grid.close()
            context.saveGState()
            grid.usesEvenOddFillRule = true
            color.setFill()
            grid.fill()
            context.restoreGState()

            /// grid
            let grid2 = UIBezierPath()
            grid2.move(to: CGPoint.zero)
            grid2.addLine(to: CGPoint(x: 8, y: 0))
            grid2.addLine(to: CGPoint(x: 8, y: 8))
            grid2.addLine(to: CGPoint(x: 0, y: 8))
            grid2.addLine(to: CGPoint.zero)
            grid2.close()
            context.saveGState()
            context.translateBy(x: 16, y: 0)
            grid2.usesEvenOddFillRule = true
            color.setFill()
            grid2.fill()
            context.restoreGState()

            /// grid
            let grid3 = UIBezierPath()
            grid3.move(to: CGPoint.zero)
            grid3.addLine(to: CGPoint(x: 8, y: 0))
            grid3.addLine(to: CGPoint(x: 8, y: 8))
            grid3.addLine(to: CGPoint(x: 0, y: 8))
            grid3.addLine(to: CGPoint.zero)
            grid3.close()
            context.saveGState()
            context.translateBy(x: 8, y: 8)
            grid3.usesEvenOddFillRule = true
            color.setFill()
            grid3.fill()
            context.restoreGState()

            /// grid
            let grid4 = UIBezierPath()
            grid4.move(to: CGPoint.zero)
            grid4.addLine(to: CGPoint(x: 8, y: 0))
            grid4.addLine(to: CGPoint(x: 8, y: 8))
            grid4.addLine(to: CGPoint(x: 0, y: 8))
            grid4.addLine(to: CGPoint.zero)
            grid4.close()
            context.saveGState()
            context.translateBy(x: 24, y: 8)
            grid4.usesEvenOddFillRule = true
            color.setFill()
            grid4.fill()
            context.restoreGState()
        }
        context.endTransparencyLayer()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawVerticalAlignmentTop(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 15, height: 11), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 15, height: 11), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 15, y: resizedFrame.height / 11)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 3, y: 1))
        icon.addLine(to: CGPoint(x: 3, y: 10))
        icon.addLine(to: CGPoint(x: 12, y: 10))
        icon.addLine(to: CGPoint(x: 12, y: 1))
        icon.addLine(to: CGPoint(x: 3, y: 1))
        icon.close()
        icon.move(to: CGPoint(x: 13, y: 11))
        icon.addLine(to: CGPoint(x: 2, y: 11))
        icon.addLine(to: CGPoint(x: 2, y: 1))
        icon.addLine(to: CGPoint(x: 0, y: 1))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 15, y: 0))
        icon.addLine(to: CGPoint(x: 15, y: 1))
        icon.addLine(to: CGPoint(x: 13, y: 1))
        icon.addLine(to: CGPoint(x: 13, y: 11))
        icon.close()
        context.saveGState()
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawVerticalAlignmentCenter(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 15, height: 11), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 15, height: 11), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 15, y: resizedFrame.height / 11)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 12.96, y: 0))
        icon.addLine(to: CGPoint(x: 12.96, y: 5))
        icon.addLine(to: CGPoint(x: 14.93, y: 5))
        icon.addLine(to: CGPoint(x: 14.93, y: 6))
        icon.addLine(to: CGPoint(x: 12.96, y: 6))
        icon.addLine(to: CGPoint(x: 12.96, y: 11))
        icon.addLine(to: CGPoint(x: 1.96, y: 11))
        icon.addLine(to: CGPoint(x: 1.96, y: 6))
        icon.addLine(to: CGPoint(x: 0, y: 6))
        icon.addLine(to: CGPoint(x: 0, y: 5))
        icon.addLine(to: CGPoint(x: 1.96, y: 5))
        icon.addLine(to: CGPoint(x: 1.96, y: 0))
        icon.addLine(to: CGPoint(x: 12.96, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 11.96, y: 6))
        icon.addLine(to: CGPoint(x: 2.96, y: 6))
        icon.addLine(to: CGPoint(x: 2.96, y: 10))
        icon.addLine(to: CGPoint(x: 11.96, y: 10))
        icon.addLine(to: CGPoint(x: 11.96, y: 6))
        icon.close()
        icon.move(to: CGPoint(x: 11.96, y: 1))
        icon.addLine(to: CGPoint(x: 2.96, y: 1))
        icon.addLine(to: CGPoint(x: 2.96, y: 5))
        icon.addLine(to: CGPoint(x: 11.96, y: 5))
        icon.addLine(to: CGPoint(x: 11.96, y: 1))
        icon.close()
        context.saveGState()
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawVerticalAlignmentBottom(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 15, height: 11), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 15, height: 11), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 15, y: resizedFrame.height / 11)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 0, y: 11))
        icon.addLine(to: CGPoint(x: 0, y: 10))
        icon.addLine(to: CGPoint(x: 2, y: 10))
        icon.addLine(to: CGPoint(x: 2, y: 0))
        icon.addLine(to: CGPoint(x: 13, y: 0))
        icon.addLine(to: CGPoint(x: 13, y: 10))
        icon.addLine(to: CGPoint(x: 15, y: 10))
        icon.addLine(to: CGPoint(x: 15, y: 11))
        icon.addLine(to: CGPoint(x: 0, y: 11))
        icon.close()
        icon.move(to: CGPoint(x: 12, y: 1))
        icon.addLine(to: CGPoint(x: 3, y: 1))
        icon.addLine(to: CGPoint(x: 3, y: 10))
        icon.addLine(to: CGPoint(x: 12, y: 10))
        icon.addLine(to: CGPoint(x: 12, y: 1))
        icon.close()
        context.saveGState()
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawVerticalAlignmentFill(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 11, height: 11), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 11, height: 11), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 11, y: resizedFrame.height / 11)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 11, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 11))
        icon.addLine(to: CGPoint(x: 0, y: 11))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 11, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 10, y: 1))
        icon.addLine(to: CGPoint(x: 5.55, y: 1))
        icon.addLine(to: CGPoint(x: 7.8, y: 4.03))
        icon.addLine(to: CGPoint(x: 6.92, y: 4.36))
        icon.addLine(to: CGPoint(x: 6, y: 3))
        icon.addLine(to: CGPoint(x: 6, y: 8))
        icon.addLine(to: CGPoint(x: 7.11, y: 6.53))
        icon.addLine(to: CGPoint(x: 7.93, y: 6.95))
        icon.addLine(to: CGPoint(x: 5.49, y: 9.93))
        icon.addLine(to: CGPoint(x: 3.08, y: 6.69))
        icon.addLine(to: CGPoint(x: 3.97, y: 6.36))
        icon.addLine(to: CGPoint(x: 5, y: 8))
        icon.addLine(to: CGPoint(x: 5, y: 3))
        icon.addLine(to: CGPoint(x: 3.86, y: 4.34))
        icon.addLine(to: CGPoint(x: 3.07, y: 3.89))
        icon.addLine(to: CGPoint(x: 5.43, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 10))
        icon.addLine(to: CGPoint(x: 10, y: 10))
        icon.addLine(to: CGPoint(x: 10, y: 1))
        icon.close()
        context.saveGState()
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawHorizontalAlignmentFill(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 11, height: 11), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 11, height: 11), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 11, y: resizedFrame.height / 11)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 11, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 11))
        icon.addLine(to: CGPoint(x: 0, y: 11))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 11, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 10, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 1))
        icon.addLine(to: CGPoint(x: 1, y: 10))
        icon.addLine(to: CGPoint(x: 10, y: 10))
        icon.addLine(to: CGPoint(x: 10, y: 1))
        icon.close()
        icon.move(to: CGPoint(x: 7.02, y: 3))
        icon.addLine(to: CGPoint(x: 10, y: 5.44))
        icon.addLine(to: CGPoint(x: 6.77, y: 7.85))
        icon.addLine(to: CGPoint(x: 6.44, y: 6.96))
        icon.addLine(to: CGPoint(x: 8, y: 6))
        icon.addLine(to: CGPoint(x: 3, y: 6))
        icon.addLine(to: CGPoint(x: 4.41, y: 7.07))
        icon.addLine(to: CGPoint(x: 3.96, y: 7.86))
        icon.addLine(to: CGPoint(x: 1, y: 5.44))
        icon.addLine(to: CGPoint(x: 4.1, y: 3.12))
        icon.addLine(to: CGPoint(x: 4.43, y: 4.01))
        icon.addLine(to: CGPoint(x: 3, y: 5))
        icon.addLine(to: CGPoint(x: 8, y: 5))
        icon.addLine(to: CGPoint(x: 6.61, y: 3.82))
        icon.addLine(to: CGPoint(x: 7.02, y: 3))
        icon.close()
        context.saveGState()
        UIColor.black.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawHorizontalAlignmentRight(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 11, height: 15), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 11, height: 15), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 11, y: resizedFrame.height / 15)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 11, y: 15))
        icon.addLine(to: CGPoint(x: 10, y: 15))
        icon.addLine(to: CGPoint(x: 10, y: 13))
        icon.addLine(to: CGPoint(x: 0, y: 13))
        icon.addLine(to: CGPoint(x: 0, y: 2))
        icon.addLine(to: CGPoint(x: 10, y: 2))
        icon.addLine(to: CGPoint(x: 10, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 15))
        icon.close()
        icon.move(to: CGPoint(x: 10, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 3))
        icon.close()
        context.saveGState()
        UIColor(hue: 0.583, saturation: 0.095, brightness: 0.082, alpha: 1).setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawHorizontalAlignmentTrailing(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 11, height: 15), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 11, height: 15), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 11, y: resizedFrame.height / 15)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 11, y: 15))
        icon.addLine(to: CGPoint(x: 10, y: 15))
        icon.addLine(to: CGPoint(x: 10, y: 13))
        icon.addLine(to: CGPoint(x: 0, y: 13))
        icon.addLine(to: CGPoint(x: 0, y: 2))
        icon.addLine(to: CGPoint(x: 10, y: 2))
        icon.addLine(to: CGPoint(x: 10, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 0))
        icon.addLine(to: CGPoint(x: 11, y: 15))
        icon.close()
        icon.move(to: CGPoint(x: 10, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 3))
        icon.close()
        icon.move(to: CGPoint(x: 8, y: 5))
        icon.addLine(to: CGPoint(x: 8, y: 6))
        icon.addLine(to: CGPoint(x: 6, y: 6))
        icon.addLine(to: CGPoint(x: 6, y: 10))
        icon.addLine(to: CGPoint(x: 5, y: 10))
        icon.addLine(to: CGPoint(x: 5, y: 6))
        icon.addLine(to: CGPoint(x: 3, y: 6))
        icon.addLine(to: CGPoint(x: 3, y: 5))
        icon.addLine(to: CGPoint(x: 8, y: 5))
        icon.close()
        context.saveGState()
        UIColor(hue: 0.583, saturation: 0.095, brightness: 0.082, alpha: 1).setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawHorizontalAlignmentCenter(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 11, height: 15), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 11, height: 15), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 11, y: resizedFrame.height / 15)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 6, y: 0))
        icon.addLine(to: CGPoint(x: 6, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 13))
        icon.addLine(to: CGPoint(x: 6, y: 13))
        icon.addLine(to: CGPoint(x: 6, y: 15))
        icon.addLine(to: CGPoint(x: 5, y: 15))
        icon.addLine(to: CGPoint(x: 5, y: 13))
        icon.addLine(to: CGPoint(x: 0, y: 13))
        icon.addLine(to: CGPoint(x: 0, y: 2))
        icon.addLine(to: CGPoint(x: 5, y: 2))
        icon.addLine(to: CGPoint(x: 5, y: 0))
        icon.addLine(to: CGPoint(x: 6, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 5, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 12))
        icon.addLine(to: CGPoint(x: 5, y: 12))
        icon.addLine(to: CGPoint(x: 5, y: 3))
        icon.close()
        icon.move(to: CGPoint(x: 10, y: 3))
        icon.addLine(to: CGPoint(x: 6, y: 3))
        icon.addLine(to: CGPoint(x: 6, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 3))
        icon.close()
        context.saveGState()
        UIColor(hue: 0.583, saturation: 0.095, brightness: 0.082, alpha: 1).setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawHorizontalAlignmentLeft(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 11, height: 15), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 11, height: 15), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 11, y: resizedFrame.height / 15)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 1, y: 0))
        icon.addLine(to: CGPoint(x: 1, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 13))
        icon.addLine(to: CGPoint(x: 1, y: 13))
        icon.addLine(to: CGPoint(x: 1, y: 15))
        icon.addLine(to: CGPoint(x: 0, y: 15))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 1, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 10, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 3))
        icon.close()
        context.saveGState()
        UIColor(hue: 0.583, saturation: 0.095, brightness: 0.082, alpha: 1).setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawHorizontalAlignmentLeading(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 11, height: 15), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 11, height: 15), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 11, y: resizedFrame.height / 15)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 1, y: 0))
        icon.addLine(to: CGPoint(x: 1, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 2))
        icon.addLine(to: CGPoint(x: 11, y: 13))
        icon.addLine(to: CGPoint(x: 1, y: 13))
        icon.addLine(to: CGPoint(x: 1, y: 15))
        icon.addLine(to: CGPoint(x: 0, y: 15))
        icon.addLine(to: CGPoint.zero)
        icon.addLine(to: CGPoint(x: 1, y: 0))
        icon.close()
        icon.move(to: CGPoint(x: 10, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 3))
        icon.addLine(to: CGPoint(x: 1, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 12))
        icon.addLine(to: CGPoint(x: 10, y: 3))
        icon.close()
        icon.move(to: CGPoint(x: 5, y: 5))
        icon.addLine(to: CGPoint(x: 5, y: 9))
        icon.addLine(to: CGPoint(x: 7, y: 9))
        icon.addLine(to: CGPoint(x: 7, y: 10))
        icon.addLine(to: CGPoint(x: 4, y: 10))
        icon.addLine(to: CGPoint(x: 4, y: 5))
        icon.addLine(to: CGPoint(x: 5, y: 5))
        icon.close()
        context.saveGState()
        UIColor(hue: 0.583, saturation: 0.095, brightness: 0.082, alpha: 1).setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawWifiExlusionMark(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 9.01, y: 9.86))
        icon.addCurve(to: CGPoint(x: 9.98, y: 8.87), controlPoint1: CGPoint(x: 9.6, y: 9.86), controlPoint2: CGPoint(x: 9.96, y: 9.48))
        icon.addCurve(to: CGPoint(x: 10.09, y: 1.06), controlPoint1: CGPoint(x: 10.01, y: 6.43), controlPoint2: CGPoint(x: 10.07, y: 3.43))
        icon.addCurve(to: CGPoint(x: 9.01, y: 0), controlPoint1: CGPoint(x: 10.09, y: 0.44), controlPoint2: CGPoint(x: 9.62, y: 0))
        icon.addCurve(to: CGPoint(x: 7.92, y: 1.06), controlPoint1: CGPoint(x: 8.39, y: 0), controlPoint2: CGPoint(x: 7.92, y: 0.44))
        icon.addCurve(to: CGPoint(x: 8.05, y: 8.87), controlPoint1: CGPoint(x: 7.95, y: 3.43), controlPoint2: CGPoint(x: 8.01, y: 6.43))
        icon.addCurve(to: CGPoint(x: 9.01, y: 9.86), controlPoint1: CGPoint(x: 8.06, y: 9.48), controlPoint2: CGPoint(x: 8.42, y: 9.86))
        icon.close()
        icon.move(to: CGPoint(x: 6.74, y: 0.97))
        icon.addCurve(to: CGPoint(x: 0.08, y: 4.74), controlPoint1: CGPoint(x: 4.01, y: 1.49), controlPoint2: CGPoint(x: 1.57, y: 2.89))
        icon.addCurve(to: CGPoint(x: 0.12, y: 5.25), controlPoint1: CGPoint(x: -0.03, y: 4.87), controlPoint2: CGPoint(x: -0.03, y: 5.09))
        icon.addLine(to: CGPoint(x: 1.22, y: 6.39))
        icon.addCurve(to: CGPoint(x: 1.83, y: 6.38), controlPoint1: CGPoint(x: 1.4, y: 6.56), controlPoint2: CGPoint(x: 1.66, y: 6.56))
        icon.addCurve(to: CGPoint(x: 6.79, y: 3.53), controlPoint1: CGPoint(x: 3.21, y: 4.89), controlPoint2: CGPoint(x: 4.9, y: 3.94))
        icon.addLine(to: CGPoint(x: 6.74, y: 0.97))
        icon.close()
        icon.move(to: CGPoint(x: 11.25, y: 0.98))
        icon.addLine(to: CGPoint(x: 11.21, y: 3.54))
        icon.addCurve(to: CGPoint(x: 16.18, y: 6.39), controlPoint1: CGPoint(x: 13.09, y: 3.93), controlPoint2: CGPoint(x: 14.76, y: 4.9))
        icon.addCurve(to: CGPoint(x: 16.77, y: 6.37), controlPoint1: CGPoint(x: 16.35, y: 6.56), controlPoint2: CGPoint(x: 16.6, y: 6.55))
        icon.addLine(to: CGPoint(x: 17.88, y: 5.25))
        icon.addCurve(to: CGPoint(x: 17.91, y: 4.74), controlPoint1: CGPoint(x: 18.04, y: 5.09), controlPoint2: CGPoint(x: 18.04, y: 4.87))
        icon.addCurve(to: CGPoint(x: 11.25, y: 0.98), controlPoint1: CGPoint(x: 16.41, y: 2.91), controlPoint2: CGPoint(x: 14.01, y: 1.47))
        icon.close()
        icon.move(to: CGPoint(x: 11.19, y: 5.64))
        icon.addLine(to: CGPoint(x: 11.15, y: 8.31))
        icon.addCurve(to: CGPoint(x: 12.99, y: 9.61), controlPoint1: CGPoint(x: 11.86, y: 8.62), controlPoint2: CGPoint(x: 12.49, y: 9.08))
        icon.addCurve(to: CGPoint(x: 13.57, y: 9.6), controlPoint1: CGPoint(x: 13.15, y: 9.79), controlPoint2: CGPoint(x: 13.38, y: 9.78))
        icon.addLine(to: CGPoint(x: 14.8, y: 8.38))
        icon.addCurve(to: CGPoint(x: 14.83, y: 7.87), controlPoint1: CGPoint(x: 14.95, y: 8.24), controlPoint2: CGPoint(x: 14.96, y: 8.03))
        icon.addCurve(to: CGPoint(x: 11.19, y: 5.64), controlPoint1: CGPoint(x: 14, y: 6.87), controlPoint2: CGPoint(x: 12.7, y: 6.02))
        icon.close()
        icon.move(to: CGPoint(x: 6.83, y: 5.64))
        icon.addCurve(to: CGPoint(x: 3.17, y: 7.87), controlPoint1: CGPoint(x: 5.31, y: 6.04), controlPoint2: CGPoint(x: 4.02, y: 6.85))
        icon.addCurve(to: CGPoint(x: 3.21, y: 8.38), controlPoint1: CGPoint(x: 3.04, y: 8.03), controlPoint2: CGPoint(x: 3.04, y: 8.23))
        icon.addLine(to: CGPoint(x: 4.44, y: 9.61))
        icon.addCurve(to: CGPoint(x: 5.06, y: 9.57), controlPoint1: CGPoint(x: 4.63, y: 9.8), controlPoint2: CGPoint(x: 4.89, y: 9.78))
        icon.addCurve(to: CGPoint(x: 6.87, y: 8.3), controlPoint1: CGPoint(x: 5.54, y: 9.05), controlPoint2: CGPoint(x: 6.16, y: 8.6))
        icon.addLine(to: CGPoint(x: 6.83, y: 5.64))
        icon.close()
        icon.move(to: CGPoint(x: 9, y: 14))
        icon.addCurve(to: CGPoint(x: 10.4, y: 12.62), controlPoint1: CGPoint(x: 9.77, y: 14), controlPoint2: CGPoint(x: 10.4, y: 13.38))
        icon.addCurve(to: CGPoint(x: 9, y: 11.23), controlPoint1: CGPoint(x: 10.4, y: 11.84), controlPoint2: CGPoint(x: 9.77, y: 11.23))
        icon.addCurve(to: CGPoint(x: 7.61, y: 12.62), controlPoint1: CGPoint(x: 8.24, y: 11.23), controlPoint2: CGPoint(x: 7.61, y: 11.84))
        icon.addCurve(to: CGPoint(x: 9, y: 14), controlPoint1: CGPoint(x: 7.61, y: 13.38), controlPoint2: CGPoint(x: 8.24, y: 14))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 5)
        color.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawEyeSlashFill(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 14.12, y: 11.83))
        icon.addCurve(to: CGPoint(x: 14.94, y: 11.83), controlPoint1: CGPoint(x: 14.34, y: 12.05), controlPoint2: CGPoint(x: 14.71, y: 12.07))
        icon.addCurve(to: CGPoint(x: 14.94, y: 11.02), controlPoint1: CGPoint(x: 15.18, y: 11.59), controlPoint2: CGPoint(x: 15.17, y: 11.25))
        icon.addLine(to: CGPoint(x: 3.87, y: 0.17))
        icon.addCurve(to: CGPoint(x: 3.04, y: 0.17), controlPoint1: CGPoint(x: 3.65, y: -0.06), controlPoint2: CGPoint(x: 3.27, y: -0.06))
        icon.addCurve(to: CGPoint(x: 3.04, y: 0.97), controlPoint1: CGPoint(x: 2.83, y: 0.38), controlPoint2: CGPoint(x: 2.83, y: 0.76))
        icon.addLine(to: CGPoint(x: 14.12, y: 11.83))
        icon.close()
        icon.move(to: CGPoint(x: 14.94, y: 9.82))
        icon.addCurve(to: CGPoint(x: 18, y: 6.13), controlPoint1: CGPoint(x: 16.8, y: 8.58), controlPoint2: CGPoint(x: 18, y: 6.89))
        icon.addCurve(to: CGPoint(x: 9, y: 0.59), controlPoint1: CGPoint(x: 18, y: 4.82), controlPoint2: CGPoint(x: 14.4, y: 0.59))
        icon.addCurve(to: CGPoint(x: 5.99, y: 1.04), controlPoint1: CGPoint(x: 7.92, y: 0.59), controlPoint2: CGPoint(x: 6.91, y: 0.76))
        icon.addLine(to: CGPoint(x: 7.79, y: 2.81))
        icon.addCurve(to: CGPoint(x: 9, y: 2.6), controlPoint1: CGPoint(x: 8.17, y: 2.68), controlPoint2: CGPoint(x: 8.58, y: 2.6))
        icon.addCurve(to: CGPoint(x: 12.62, y: 6.13), controlPoint1: CGPoint(x: 11.01, y: 2.6), controlPoint2: CGPoint(x: 12.62, y: 4.16))
        icon.addCurve(to: CGPoint(x: 12.39, y: 7.33), controlPoint1: CGPoint(x: 12.62, y: 6.55), controlPoint2: CGPoint(x: 12.54, y: 6.96))
        icon.addLine(to: CGPoint(x: 14.94, y: 9.82))
        icon.close()
        icon.move(to: CGPoint(x: 9, y: 11.68))
        icon.addCurve(to: CGPoint(x: 12.25, y: 11.14), controlPoint1: CGPoint(x: 10.19, y: 11.68), controlPoint2: CGPoint(x: 11.28, y: 11.48))
        icon.addLine(to: CGPoint(x: 10.44, y: 9.37))
        icon.addCurve(to: CGPoint(x: 9, y: 9.67), controlPoint1: CGPoint(x: 10, y: 9.56), controlPoint2: CGPoint(x: 9.52, y: 9.67))
        icon.addCurve(to: CGPoint(x: 5.39, y: 6.13), controlPoint1: CGPoint(x: 6.99, y: 9.67), controlPoint2: CGPoint(x: 5.39, y: 8.06))
        icon.addCurve(to: CGPoint(x: 5.69, y: 4.71), controlPoint1: CGPoint(x: 5.38, y: 5.62), controlPoint2: CGPoint(x: 5.49, y: 5.15))
        icon.addLine(to: CGPoint(x: 3.27, y: 2.33))
        icon.addCurve(to: CGPoint(x: 0, y: 6.13), controlPoint1: CGPoint(x: 1.25, y: 3.61), controlPoint2: CGPoint(x: 0, y: 5.37))
        icon.addCurve(to: CGPoint(x: 9, y: 11.68), controlPoint1: CGPoint(x: 0, y: 7.45), controlPoint2: CGPoint(x: 3.7, y: 11.68))
        icon.close()
        icon.move(to: CGPoint(x: 11.25, y: 5.98))
        icon.addCurve(to: CGPoint(x: 9.02, y: 3.8), controlPoint1: CGPoint(x: 11.25, y: 4.77), controlPoint2: CGPoint(x: 10.26, y: 3.8))
        icon.addCurve(to: CGPoint(x: 8.8, y: 3.8), controlPoint1: CGPoint(x: 8.95, y: 3.8), controlPoint2: CGPoint(x: 8.88, y: 3.8))
        icon.addLine(to: CGPoint(x: 11.23, y: 6.19))
        icon.addCurve(to: CGPoint(x: 11.25, y: 5.98), controlPoint1: CGPoint(x: 11.24, y: 6.12), controlPoint2: CGPoint(x: 11.25, y: 6.05))
        icon.close()
        icon.move(to: CGPoint(x: 6.75, y: 6))
        icon.addCurve(to: CGPoint(x: 8.99, y: 8.18), controlPoint1: CGPoint(x: 6.75, y: 7.2), controlPoint2: CGPoint(x: 7.76, y: 8.18))
        icon.addCurve(to: CGPoint(x: 9.22, y: 8.17), controlPoint1: CGPoint(x: 9.06, y: 8.18), controlPoint2: CGPoint(x: 9.14, y: 8.18))
        icon.addLine(to: CGPoint(x: 6.76, y: 5.75))
        icon.addCurve(to: CGPoint(x: 6.75, y: 6), controlPoint1: CGPoint(x: 6.76, y: 5.84), controlPoint2: CGPoint(x: 6.75, y: 5.92))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 6)
        color.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawListBulletIndent(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)

        /// Parent
        let parent = UIBezierPath()
        parent.move(to: CGPoint(x: 2.51, y: 0))
        parent.addLine(to: CGPoint(x: 3.49, y: 0))
        parent.addCurve(to: CGPoint(x: 4.98, y: 0.27), controlPoint1: CGPoint(x: 4.32, y: 0), controlPoint2: CGPoint(x: 4.65, y: 0.09))
        parent.addCurve(to: CGPoint(x: 5.73, y: 1.02), controlPoint1: CGPoint(x: 5.3, y: 0.44), controlPoint2: CGPoint(x: 5.56, y: 0.7))
        parent.addCurve(to: CGPoint(x: 6, y: 2.51), controlPoint1: CGPoint(x: 5.91, y: 1.35), controlPoint2: CGPoint(x: 6, y: 1.68))
        parent.addLine(to: CGPoint(x: 6, y: 3.49))
        parent.addCurve(to: CGPoint(x: 5.73, y: 4.98), controlPoint1: CGPoint(x: 6, y: 4.32), controlPoint2: CGPoint(x: 5.91, y: 4.65))
        parent.addCurve(to: CGPoint(x: 4.98, y: 5.73), controlPoint1: CGPoint(x: 5.56, y: 5.3), controlPoint2: CGPoint(x: 5.3, y: 5.56))
        parent.addCurve(to: CGPoint(x: 3.49, y: 6), controlPoint1: CGPoint(x: 4.65, y: 5.91), controlPoint2: CGPoint(x: 4.32, y: 6))
        parent.addLine(to: CGPoint(x: 2.51, y: 6))
        parent.addCurve(to: CGPoint(x: 1.02, y: 5.73), controlPoint1: CGPoint(x: 1.68, y: 6), controlPoint2: CGPoint(x: 1.35, y: 5.91))
        parent.addCurve(to: CGPoint(x: 0.27, y: 4.98), controlPoint1: CGPoint(x: 0.7, y: 5.56), controlPoint2: CGPoint(x: 0.44, y: 5.3))
        parent.addCurve(to: CGPoint(x: 0, y: 3.49), controlPoint1: CGPoint(x: 0.09, y: 4.65), controlPoint2: CGPoint(x: 0, y: 4.32))
        parent.addLine(to: CGPoint(x: 0, y: 2.51))
        parent.addCurve(to: CGPoint(x: 0.27, y: 1.02), controlPoint1: CGPoint(x: 0, y: 1.68), controlPoint2: CGPoint(x: 0.09, y: 1.35))
        parent.addCurve(to: CGPoint(x: 1.02, y: 0.27), controlPoint1: CGPoint(x: 0.44, y: 0.7), controlPoint2: CGPoint(x: 0.7, y: 0.44))
        parent.addCurve(to: CGPoint(x: 2.51, y: 0), controlPoint1: CGPoint(x: 1.35, y: 0.09), controlPoint2: CGPoint(x: 1.68, y: 0))
        parent.close()
        context.saveGState()
        context.translateBy(x: 9, y: 3)
        parent.usesEvenOddFillRule = true
        UIColor.black.setFill()
        parent.fill()
        context.restoreGState()

        /// Child
        let child = UIBezierPath()
        child.move(to: CGPoint(x: 1.79, y: 0))
        child.addLine(to: CGPoint(x: 2.21, y: 0))
        child.addCurve(to: CGPoint(x: 3.23, y: 0.2), controlPoint1: CGPoint(x: 2.72, y: 0), controlPoint2: CGPoint(x: 2.99, y: 0.07))
        child.addCurve(to: CGPoint(x: 3.8, y: 0.77), controlPoint1: CGPoint(x: 3.48, y: 0.33), controlPoint2: CGPoint(x: 3.67, y: 0.52))
        child.addCurve(to: CGPoint(x: 4, y: 1.79), controlPoint1: CGPoint(x: 3.93, y: 1.01), controlPoint2: CGPoint(x: 4, y: 1.28))
        child.addLine(to: CGPoint(x: 4, y: 2.21))
        child.addCurve(to: CGPoint(x: 3.8, y: 3.23), controlPoint1: CGPoint(x: 4, y: 2.72), controlPoint2: CGPoint(x: 3.93, y: 2.99))
        child.addCurve(to: CGPoint(x: 3.23, y: 3.8), controlPoint1: CGPoint(x: 3.67, y: 3.48), controlPoint2: CGPoint(x: 3.48, y: 3.67))
        child.addCurve(to: CGPoint(x: 2.21, y: 4), controlPoint1: CGPoint(x: 2.99, y: 3.93), controlPoint2: CGPoint(x: 2.72, y: 4))
        child.addLine(to: CGPoint(x: 1.79, y: 4))
        child.addCurve(to: CGPoint(x: 0.77, y: 3.8), controlPoint1: CGPoint(x: 1.28, y: 4), controlPoint2: CGPoint(x: 1.01, y: 3.93))
        child.addCurve(to: CGPoint(x: 0.2, y: 3.23), controlPoint1: CGPoint(x: 0.52, y: 3.67), controlPoint2: CGPoint(x: 0.33, y: 3.48))
        child.addCurve(to: CGPoint(x: 0, y: 2.21), controlPoint1: CGPoint(x: 0.07, y: 2.99), controlPoint2: CGPoint(x: 0, y: 2.72))
        child.addLine(to: CGPoint(x: 0, y: 1.79))
        child.addCurve(to: CGPoint(x: 0.2, y: 0.77), controlPoint1: CGPoint(x: 0, y: 1.28), controlPoint2: CGPoint(x: 0.07, y: 1.01))
        child.addCurve(to: CGPoint(x: 0.77, y: 0.2), controlPoint1: CGPoint(x: 0.33, y: 0.52), controlPoint2: CGPoint(x: 0.52, y: 0.33))
        child.addCurve(to: CGPoint(x: 1.79, y: 0), controlPoint1: CGPoint(x: 1.01, y: 0.07), controlPoint2: CGPoint(x: 1.28, y: 0))
        child.close()
        context.saveGState()
        context.translateBy(x: 3, y: 17)
        child.usesEvenOddFillRule = true
        UIColor.black.setFill()
        child.fill()
        context.restoreGState()

        /// Child
        let child2 = UIBezierPath()
        child2.move(to: CGPoint(x: 1.79, y: 0))
        child2.addLine(to: CGPoint(x: 2.21, y: 0))
        child2.addCurve(to: CGPoint(x: 3.23, y: 0.2), controlPoint1: CGPoint(x: 2.72, y: 0), controlPoint2: CGPoint(x: 2.99, y: 0.07))
        child2.addCurve(to: CGPoint(x: 3.8, y: 0.77), controlPoint1: CGPoint(x: 3.48, y: 0.33), controlPoint2: CGPoint(x: 3.67, y: 0.52))
        child2.addCurve(to: CGPoint(x: 4, y: 1.79), controlPoint1: CGPoint(x: 3.93, y: 1.01), controlPoint2: CGPoint(x: 4, y: 1.28))
        child2.addLine(to: CGPoint(x: 4, y: 2.21))
        child2.addCurve(to: CGPoint(x: 3.8, y: 3.23), controlPoint1: CGPoint(x: 4, y: 2.72), controlPoint2: CGPoint(x: 3.93, y: 2.99))
        child2.addCurve(to: CGPoint(x: 3.23, y: 3.8), controlPoint1: CGPoint(x: 3.67, y: 3.48), controlPoint2: CGPoint(x: 3.48, y: 3.67))
        child2.addCurve(to: CGPoint(x: 2.21, y: 4), controlPoint1: CGPoint(x: 2.99, y: 3.93), controlPoint2: CGPoint(x: 2.72, y: 4))
        child2.addLine(to: CGPoint(x: 1.79, y: 4))
        child2.addCurve(to: CGPoint(x: 0.77, y: 3.8), controlPoint1: CGPoint(x: 1.28, y: 4), controlPoint2: CGPoint(x: 1.01, y: 3.93))
        child2.addCurve(to: CGPoint(x: 0.2, y: 3.23), controlPoint1: CGPoint(x: 0.52, y: 3.67), controlPoint2: CGPoint(x: 0.33, y: 3.48))
        child2.addCurve(to: CGPoint(x: 0, y: 2.21), controlPoint1: CGPoint(x: 0.07, y: 2.99), controlPoint2: CGPoint(x: 0, y: 2.72))
        child2.addLine(to: CGPoint(x: 0, y: 1.79))
        child2.addCurve(to: CGPoint(x: 0.2, y: 0.77), controlPoint1: CGPoint(x: 0, y: 1.28), controlPoint2: CGPoint(x: 0.07, y: 1.01))
        child2.addCurve(to: CGPoint(x: 0.77, y: 0.2), controlPoint1: CGPoint(x: 0.33, y: 0.52), controlPoint2: CGPoint(x: 0.52, y: 0.33))
        child2.addCurve(to: CGPoint(x: 1.79, y: 0), controlPoint1: CGPoint(x: 1.01, y: 0.07), controlPoint2: CGPoint(x: 1.28, y: 0))
        child2.close()
        context.saveGState()
        context.translateBy(x: 10, y: 17)
        child2.usesEvenOddFillRule = true
        UIColor.black.setFill()
        child2.fill()
        context.restoreGState()

        /// Child
        let child3 = UIBezierPath()
        child3.move(to: CGPoint(x: 1.79, y: 0))
        child3.addLine(to: CGPoint(x: 2.21, y: 0))
        child3.addCurve(to: CGPoint(x: 3.23, y: 0.2), controlPoint1: CGPoint(x: 2.72, y: 0), controlPoint2: CGPoint(x: 2.99, y: 0.07))
        child3.addCurve(to: CGPoint(x: 3.8, y: 0.77), controlPoint1: CGPoint(x: 3.48, y: 0.33), controlPoint2: CGPoint(x: 3.67, y: 0.52))
        child3.addCurve(to: CGPoint(x: 4, y: 1.79), controlPoint1: CGPoint(x: 3.93, y: 1.01), controlPoint2: CGPoint(x: 4, y: 1.28))
        child3.addLine(to: CGPoint(x: 4, y: 2.21))
        child3.addCurve(to: CGPoint(x: 3.8, y: 3.23), controlPoint1: CGPoint(x: 4, y: 2.72), controlPoint2: CGPoint(x: 3.93, y: 2.99))
        child3.addCurve(to: CGPoint(x: 3.23, y: 3.8), controlPoint1: CGPoint(x: 3.67, y: 3.48), controlPoint2: CGPoint(x: 3.48, y: 3.67))
        child3.addCurve(to: CGPoint(x: 2.21, y: 4), controlPoint1: CGPoint(x: 2.99, y: 3.93), controlPoint2: CGPoint(x: 2.72, y: 4))
        child3.addLine(to: CGPoint(x: 1.79, y: 4))
        child3.addCurve(to: CGPoint(x: 0.77, y: 3.8), controlPoint1: CGPoint(x: 1.28, y: 4), controlPoint2: CGPoint(x: 1.01, y: 3.93))
        child3.addCurve(to: CGPoint(x: 0.2, y: 3.23), controlPoint1: CGPoint(x: 0.52, y: 3.67), controlPoint2: CGPoint(x: 0.33, y: 3.48))
        child3.addCurve(to: CGPoint(x: 0, y: 2.21), controlPoint1: CGPoint(x: 0.07, y: 2.99), controlPoint2: CGPoint(x: 0, y: 2.72))
        child3.addLine(to: CGPoint(x: 0, y: 1.79))
        child3.addCurve(to: CGPoint(x: 0.2, y: 0.77), controlPoint1: CGPoint(x: 0, y: 1.28), controlPoint2: CGPoint(x: 0.07, y: 1.01))
        child3.addCurve(to: CGPoint(x: 0.77, y: 0.2), controlPoint1: CGPoint(x: 0.33, y: 0.52), controlPoint2: CGPoint(x: 0.52, y: 0.33))
        child3.addCurve(to: CGPoint(x: 1.79, y: 0), controlPoint1: CGPoint(x: 1.01, y: 0.07), controlPoint2: CGPoint(x: 1.28, y: 0))
        child3.close()
        context.saveGState()
        context.translateBy(x: 17, y: 17)
        child3.usesEvenOddFillRule = true
        UIColor.black.setFill()
        child3.fill()
        context.restoreGState()

        /// Connection
        let connection = UIBezierPath()
        connection.move(to: CGPoint(x: 7.5, y: 0))
        connection.addCurve(to: CGPoint(x: 8, y: 0.5), controlPoint1: CGPoint(x: 7.78, y: 0), controlPoint2: CGPoint(x: 8, y: 0.22))
        connection.addLine(to: CGPoint(x: 8, y: 0.5))
        connection.addLine(to: CGPoint(x: 8, y: 1.5))
        connection.addLine(to: CGPoint(x: 13.5, y: 1.5))
        connection.addCurve(to: CGPoint(x: 14.99, y: 2.86), controlPoint1: CGPoint(x: 14.28, y: 1.5), controlPoint2: CGPoint(x: 14.92, y: 2.09))
        connection.addLine(to: CGPoint(x: 15, y: 3))
        connection.addLine(to: CGPoint(x: 15, y: 4.5))
        connection.addCurve(to: CGPoint(x: 14.5, y: 5), controlPoint1: CGPoint(x: 15, y: 4.78), controlPoint2: CGPoint(x: 14.78, y: 5))
        connection.addCurve(to: CGPoint(x: 14, y: 4.5), controlPoint1: CGPoint(x: 14.22, y: 5), controlPoint2: CGPoint(x: 14, y: 4.78))
        connection.addLine(to: CGPoint(x: 14, y: 4.5))
        connection.addLine(to: CGPoint(x: 14, y: 3))
        connection.addCurve(to: CGPoint(x: 13.5, y: 2.5), controlPoint1: CGPoint(x: 14, y: 2.72), controlPoint2: CGPoint(x: 13.78, y: 2.5))
        connection.addLine(to: CGPoint(x: 13.5, y: 2.5))
        connection.addLine(to: CGPoint(x: 8, y: 2.5))
        connection.addLine(to: CGPoint(x: 8, y: 4.5))
        connection.addCurve(to: CGPoint(x: 7.59, y: 4.99), controlPoint1: CGPoint(x: 8, y: 4.75), controlPoint2: CGPoint(x: 7.82, y: 4.95))
        connection.addLine(to: CGPoint(x: 7.5, y: 5))
        connection.addCurve(to: CGPoint(x: 7, y: 4.5), controlPoint1: CGPoint(x: 7.22, y: 5), controlPoint2: CGPoint(x: 7, y: 4.78))
        connection.addLine(to: CGPoint(x: 7, y: 4.5))
        connection.addLine(to: CGPoint(x: 7, y: 2.5))
        connection.addLine(to: CGPoint(x: 1.5, y: 2.5))
        connection.addCurve(to: CGPoint(x: 1.01, y: 2.91), controlPoint1: CGPoint(x: 1.25, y: 2.5), controlPoint2: CGPoint(x: 1.05, y: 2.68))
        connection.addLine(to: CGPoint(x: 1, y: 3))
        connection.addLine(to: CGPoint(x: 1, y: 4.5))
        connection.addCurve(to: CGPoint(x: 0.5, y: 5), controlPoint1: CGPoint(x: 1, y: 4.78), controlPoint2: CGPoint(x: 0.78, y: 5))
        connection.addCurve(to: CGPoint(x: 0, y: 4.5), controlPoint1: CGPoint(x: 0.22, y: 5), controlPoint2: CGPoint(x: 0, y: 4.78))
        connection.addLine(to: CGPoint(x: 0, y: 4.5))
        connection.addLine(to: CGPoint(x: 0, y: 3))
        connection.addCurve(to: CGPoint(x: 1.5, y: 1.5), controlPoint1: CGPoint(x: 0, y: 2.17), controlPoint2: CGPoint(x: 0.67, y: 1.5))
        connection.addLine(to: CGPoint(x: 1.5, y: 1.5))
        connection.addLine(to: CGPoint(x: 7, y: 1.5))
        connection.addLine(to: CGPoint(x: 7, y: 0.5))
        connection.addCurve(to: CGPoint(x: 7.41, y: 0.01), controlPoint1: CGPoint(x: 7, y: 0.25), controlPoint2: CGPoint(x: 7.18, y: 0.05))
        connection.close()
        context.saveGState()
        context.translateBy(x: 4.5, y: 10.5)
        connection.usesEvenOddFillRule = true
        UIColor.black.setFill()
        connection.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawInfoCircleFill(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 9, y: 18))
        icon.addCurve(to: CGPoint(x: 12.48, y: 17.29), controlPoint1: CGPoint(x: 10.23, y: 18), controlPoint2: CGPoint(x: 11.4, y: 17.76))
        icon.addCurve(to: CGPoint(x: 15.35, y: 15.34), controlPoint1: CGPoint(x: 13.57, y: 16.82), controlPoint2: CGPoint(x: 14.52, y: 16.17))
        icon.addCurve(to: CGPoint(x: 17.3, y: 12.48), controlPoint1: CGPoint(x: 16.18, y: 14.52), controlPoint2: CGPoint(x: 16.83, y: 13.56))
        icon.addCurve(to: CGPoint(x: 18, y: 9), controlPoint1: CGPoint(x: 17.77, y: 11.39), controlPoint2: CGPoint(x: 18, y: 10.23))
        icon.addCurve(to: CGPoint(x: 17.3, y: 5.52), controlPoint1: CGPoint(x: 18, y: 7.77), controlPoint2: CGPoint(x: 17.77, y: 6.61))
        icon.addCurve(to: CGPoint(x: 15.35, y: 2.65), controlPoint1: CGPoint(x: 16.83, y: 4.44), controlPoint2: CGPoint(x: 16.18, y: 3.48))
        icon.addCurve(to: CGPoint(x: 12.47, y: 0.7), controlPoint1: CGPoint(x: 14.52, y: 1.82), controlPoint2: CGPoint(x: 13.56, y: 1.17))
        icon.addCurve(to: CGPoint(x: 8.99, y: 0), controlPoint1: CGPoint(x: 11.39, y: 0.23), controlPoint2: CGPoint(x: 10.23, y: 0))
        icon.addCurve(to: CGPoint(x: 5.53, y: 0.7), controlPoint1: CGPoint(x: 7.77, y: 0), controlPoint2: CGPoint(x: 6.61, y: 0.23))
        icon.addCurve(to: CGPoint(x: 2.65, y: 2.65), controlPoint1: CGPoint(x: 4.44, y: 1.17), controlPoint2: CGPoint(x: 3.48, y: 1.82))
        icon.addCurve(to: CGPoint(x: 0.7, y: 5.52), controlPoint1: CGPoint(x: 1.82, y: 3.48), controlPoint2: CGPoint(x: 1.17, y: 4.44))
        icon.addCurve(to: CGPoint(x: 0, y: 9), controlPoint1: CGPoint(x: 0.23, y: 6.61), controlPoint2: CGPoint(x: 0, y: 7.77))
        icon.addCurve(to: CGPoint(x: 0.71, y: 12.48), controlPoint1: CGPoint(x: 0, y: 10.23), controlPoint2: CGPoint(x: 0.24, y: 11.39))
        icon.addCurve(to: CGPoint(x: 2.66, y: 15.34), controlPoint1: CGPoint(x: 1.18, y: 13.56), controlPoint2: CGPoint(x: 1.83, y: 14.52))
        icon.addCurve(to: CGPoint(x: 5.53, y: 17.29), controlPoint1: CGPoint(x: 3.48, y: 16.17), controlPoint2: CGPoint(x: 4.44, y: 16.82))
        icon.addCurve(to: CGPoint(x: 9, y: 18), controlPoint1: CGPoint(x: 6.61, y: 17.76), controlPoint2: CGPoint(x: 7.77, y: 18))
        icon.close()
        icon.move(to: CGPoint(x: 7.4, y: 13.97))
        icon.addCurve(to: CGPoint(x: 6.9, y: 13.78), controlPoint1: CGPoint(x: 7.21, y: 13.97), controlPoint2: CGPoint(x: 7.04, y: 13.91))
        icon.addCurve(to: CGPoint(x: 6.69, y: 13.29), controlPoint1: CGPoint(x: 6.76, y: 13.65), controlPoint2: CGPoint(x: 6.69, y: 13.48))
        icon.addCurve(to: CGPoint(x: 6.9, y: 12.81), controlPoint1: CGPoint(x: 6.69, y: 13.1), controlPoint2: CGPoint(x: 6.76, y: 12.94))
        icon.addCurve(to: CGPoint(x: 7.4, y: 12.6), controlPoint1: CGPoint(x: 7.04, y: 12.67), controlPoint2: CGPoint(x: 7.21, y: 12.6))
        icon.addLine(to: CGPoint(x: 8.49, y: 12.6))
        icon.addLine(to: CGPoint(x: 8.49, y: 8.68))
        icon.addLine(to: CGPoint(x: 7.56, y: 8.68))
        icon.addCurve(to: CGPoint(x: 7.06, y: 8.49), controlPoint1: CGPoint(x: 7.36, y: 8.68), controlPoint2: CGPoint(x: 7.19, y: 8.61))
        icon.addCurve(to: CGPoint(x: 6.85, y: 7.99), controlPoint1: CGPoint(x: 6.92, y: 8.36), controlPoint2: CGPoint(x: 6.85, y: 8.19))
        icon.addCurve(to: CGPoint(x: 7.06, y: 7.51), controlPoint1: CGPoint(x: 6.85, y: 7.81), controlPoint2: CGPoint(x: 6.92, y: 7.65))
        icon.addCurve(to: CGPoint(x: 7.56, y: 7.31), controlPoint1: CGPoint(x: 7.19, y: 7.38), controlPoint2: CGPoint(x: 7.36, y: 7.31))
        icon.addLine(to: CGPoint(x: 9.28, y: 7.31))
        icon.addCurve(to: CGPoint(x: 9.84, y: 7.56), controlPoint1: CGPoint(x: 9.52, y: 7.31), controlPoint2: CGPoint(x: 9.71, y: 7.4))
        icon.addCurve(to: CGPoint(x: 10.03, y: 8.19), controlPoint1: CGPoint(x: 9.96, y: 7.72), controlPoint2: CGPoint(x: 10.03, y: 7.93))
        icon.addLine(to: CGPoint(x: 10.03, y: 12.6))
        icon.addLine(to: CGPoint(x: 11.08, y: 12.6))
        icon.addCurve(to: CGPoint(x: 11.58, y: 12.81), controlPoint1: CGPoint(x: 11.28, y: 12.6), controlPoint2: CGPoint(x: 11.45, y: 12.67))
        icon.addCurve(to: CGPoint(x: 11.79, y: 13.29), controlPoint1: CGPoint(x: 11.72, y: 12.94), controlPoint2: CGPoint(x: 11.79, y: 13.1))
        icon.addCurve(to: CGPoint(x: 11.58, y: 13.78), controlPoint1: CGPoint(x: 11.79, y: 13.48), controlPoint2: CGPoint(x: 11.72, y: 13.65))
        icon.addCurve(to: CGPoint(x: 11.08, y: 13.97), controlPoint1: CGPoint(x: 11.45, y: 13.91), controlPoint2: CGPoint(x: 11.28, y: 13.97))
        icon.addLine(to: CGPoint(x: 7.4, y: 13.97))
        icon.close()
        icon.move(to: CGPoint(x: 8.94, y: 5.87))
        icon.addCurve(to: CGPoint(x: 8.06, y: 5.51), controlPoint1: CGPoint(x: 8.59, y: 5.87), controlPoint2: CGPoint(x: 8.3, y: 5.75))
        icon.addCurve(to: CGPoint(x: 7.71, y: 4.65), controlPoint1: CGPoint(x: 7.83, y: 5.28), controlPoint2: CGPoint(x: 7.71, y: 4.99))
        icon.addCurve(to: CGPoint(x: 8.06, y: 3.77), controlPoint1: CGPoint(x: 7.71, y: 4.3), controlPoint2: CGPoint(x: 7.83, y: 4.01))
        icon.addCurve(to: CGPoint(x: 8.94, y: 3.42), controlPoint1: CGPoint(x: 8.3, y: 3.54), controlPoint2: CGPoint(x: 8.59, y: 3.42))
        icon.addCurve(to: CGPoint(x: 9.79, y: 3.77), controlPoint1: CGPoint(x: 9.27, y: 3.42), controlPoint2: CGPoint(x: 9.55, y: 3.54))
        icon.addCurve(to: CGPoint(x: 10.15, y: 4.65), controlPoint1: CGPoint(x: 10.03, y: 4.01), controlPoint2: CGPoint(x: 10.15, y: 4.3))
        icon.addCurve(to: CGPoint(x: 9.79, y: 5.51), controlPoint1: CGPoint(x: 10.15, y: 4.99), controlPoint2: CGPoint(x: 10.03, y: 5.28))
        icon.addCurve(to: CGPoint(x: 8.94, y: 5.87), controlPoint1: CGPoint(x: 9.55, y: 5.75), controlPoint2: CGPoint(x: 9.27, y: 5.87))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 3)
        color.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawSizeArrowHorizontal(color: UIColor = .black, gapWidth: CGFloat = 0, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 9, height: 7)) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Line 1
        let line1 = UIBezierPath()
        line1.move(to: CGPoint(x: targetFrame.midX - gapWidth / 2, y: targetFrame.midY - 0.5))
        line1.addLine(to: CGPoint(x: targetFrame.midX - gapWidth / 2, y: targetFrame.midY + 0.5))
        line1.addLine(to: CGPoint(x: targetFrame.minX + 3.5, y: targetFrame.midY + 0.5))
        line1.addLine(to: CGPoint(x: targetFrame.minX + 3.5, y: targetFrame.midY - 0.5))
        line1.close()
        context.saveGState()
        line1.usesEvenOddFillRule = true
        color.setFill()
        line1.fill()
        context.restoreGState()

        /// Line 2
        let line2 = UIBezierPath()
        line2.move(to: CGPoint(x: targetFrame.maxX - 3.5, y: targetFrame.midY - 0.5))
        line2.addLine(to: CGPoint(x: targetFrame.maxX - 3.5, y: targetFrame.midY + 0.5))
        line2.addLine(to: CGPoint(x: targetFrame.midX + gapWidth / 2, y: targetFrame.midY + 0.5))
        line2.addLine(to: CGPoint(x: targetFrame.midX + gapWidth / 2, y: targetFrame.midY - 0.5))
        line2.close()
        context.saveGState()
        line2.usesEvenOddFillRule = true
        color.setFill()
        line2.fill()
        context.restoreGState()

        /// Triangle Left
        let triangleLeft = UIBezierPath()
        triangleLeft.move(to: CGPoint(x: targetFrame.minX + 4, y: targetFrame.midY - 3.5))
        triangleLeft.addLine(to: CGPoint(x: targetFrame.minX + 4, y: targetFrame.midY + 3.5))
        triangleLeft.addLine(to: CGPoint(x: targetFrame.minX + 0, y: targetFrame.midY + 0.0))
        triangleLeft.addLine(to: CGPoint(x: targetFrame.minX + 0, y: targetFrame.midY - 0.0))
        triangleLeft.close()
        context.saveGState()
        triangleLeft.usesEvenOddFillRule = true
        color.setFill()
        triangleLeft.fill()
        context.restoreGState()

        /// Triangle Right
        let triangleRight = UIBezierPath()
        triangleRight.move(to: CGPoint(x: targetFrame.maxX - 4, y: targetFrame.midY - 3.5))
        triangleRight.addLine(to: CGPoint(x: targetFrame.maxX - 4, y: targetFrame.midY + 3.5))
        triangleRight.addLine(to: CGPoint(x: targetFrame.maxX - 0, y: targetFrame.midY + 0.0))
        triangleRight.addLine(to: CGPoint(x: targetFrame.maxX - 0, y: targetFrame.midY - 0.0))
        triangleRight.close()
        context.saveGState()
        triangleRight.usesEvenOddFillRule = true
        color.setFill()
        triangleRight.fill()
        context.restoreGState()
    }

    class func drawSizeArrowVertical(color: UIColor = .black, gapHeight: CGFloat = 0, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 7, height: 9)) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Line 1
        let line1 = UIBezierPath()
        line1.move(to: CGPoint(x: targetFrame.midX + 0.5, y: targetFrame.minY + 4))
        line1.addLine(to: CGPoint(x: targetFrame.midX + 0.5, y: targetFrame.midY - gapHeight / 2))
        line1.addLine(to: CGPoint(x: targetFrame.midX - 0.5, y: targetFrame.midY - gapHeight / 2))
        line1.addLine(to: CGPoint(x: targetFrame.midX - 0.5, y: targetFrame.minY + 4))
        line1.close()
        context.saveGState()
        line1.usesEvenOddFillRule = true
        color.setFill()
        line1.fill()
        context.restoreGState()

        /// Line 2
        let line2 = UIBezierPath()
        line2.move(to: CGPoint(x: targetFrame.midX + 0.5, y: targetFrame.midY + gapHeight / 2))
        line2.addLine(to: CGPoint(x: targetFrame.midX + 0.5, y: targetFrame.maxY - 4))
        line2.addLine(to: CGPoint(x: targetFrame.midX - 0.5, y: targetFrame.maxY - 4))
        line2.addLine(to: CGPoint(x: targetFrame.midX - 0.5, y: targetFrame.midY + gapHeight / 2))
        line2.close()
        context.saveGState()
        line2.usesEvenOddFillRule = true
        color.setFill()
        line2.fill()
        context.restoreGState()

        /// Triangle Up
        let triangleUp = UIBezierPath()
        triangleUp.move(to: CGPoint(x: targetFrame.midX + 0.0, y: 0))
        triangleUp.addLine(to: CGPoint(x: targetFrame.midX + 3.5, y: 4))
        triangleUp.addLine(to: CGPoint(x: targetFrame.midX - 3.5, y: 4))
        triangleUp.addLine(to: CGPoint(x: targetFrame.midX + 0.0, y: 0))
        triangleUp.close()
        context.saveGState()
        triangleUp.usesEvenOddFillRule = true
        color.setFill()
        triangleUp.fill()
        context.restoreGState()

        /// Triangle Down
        let triangleDown = UIBezierPath()
        triangleDown.move(to: CGPoint(x: targetFrame.midX + 0.0, y: targetFrame.maxY + 0))
        triangleDown.addLine(to: CGPoint(x: targetFrame.midX + 3.5, y: targetFrame.maxY - 4))
        triangleDown.addLine(to: CGPoint(x: targetFrame.midX - 3.5, y: targetFrame.maxY - 4))
        triangleDown.addLine(to: CGPoint(x: targetFrame.midX + 0.0, y: targetFrame.maxY + 0))
        triangleDown.close()
        context.saveGState()
        triangleDown.usesEvenOddFillRule = true
        color.setFill()
        triangleDown.fill()
        context.restoreGState()
    }

    class func drawChevronUpDown(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 5, y: 6))
        icon.addCurve(to: CGPoint(x: 5.55, y: 5.75), controlPoint1: CGPoint(x: 5.21, y: 6), controlPoint2: CGPoint(x: 5.4, y: 5.92))
        icon.addLine(to: CGPoint(x: 9.8, y: 1.28))
        icon.addCurve(to: CGPoint(x: 10, y: 0.75), controlPoint1: CGPoint(x: 9.93, y: 1.14), controlPoint2: CGPoint(x: 10, y: 0.96))
        icon.addCurve(to: CGPoint(x: 9.29, y: 0), controlPoint1: CGPoint(x: 10, y: 0.33), controlPoint2: CGPoint(x: 9.69, y: 0))
        icon.addCurve(to: CGPoint(x: 8.77, y: 0.23), controlPoint1: CGPoint(x: 9.1, y: 0), controlPoint2: CGPoint(x: 8.91, y: 0.09))
        icon.addLine(to: CGPoint(x: 5, y: 4.21))
        icon.addLine(to: CGPoint(x: 1.23, y: 0.23))
        icon.addCurve(to: CGPoint(x: 0.71, y: 0), controlPoint1: CGPoint(x: 1.09, y: 0.09), controlPoint2: CGPoint(x: 0.91, y: 0))
        icon.addCurve(to: CGPoint(x: 0, y: 0.75), controlPoint1: CGPoint(x: 0.31, y: 0), controlPoint2: CGPoint(x: 0, y: 0.33))
        icon.addCurve(to: CGPoint(x: 0.2, y: 1.28), controlPoint1: CGPoint(x: 0, y: 0.96), controlPoint2: CGPoint(x: 0.07, y: 1.14))
        icon.addLine(to: CGPoint(x: 4.45, y: 5.75))
        icon.addCurve(to: CGPoint(x: 5, y: 6), controlPoint1: CGPoint(x: 4.62, y: 5.92), controlPoint2: CGPoint(x: 4.8, y: 6))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 10)
        color.setFill()
        icon.fill()
        context.restoreGState()

        /// icon copy
        let iconCopy = UIBezierPath()
        iconCopy.move(to: CGPoint(x: 5, y: 6))
        iconCopy.addCurve(to: CGPoint(x: 5.55, y: 5.75), controlPoint1: CGPoint(x: 5.21, y: 6), controlPoint2: CGPoint(x: 5.4, y: 5.92))
        iconCopy.addLine(to: CGPoint(x: 9.8, y: 1.28))
        iconCopy.addCurve(to: CGPoint(x: 10, y: 0.75), controlPoint1: CGPoint(x: 9.93, y: 1.14), controlPoint2: CGPoint(x: 10, y: 0.96))
        iconCopy.addCurve(to: CGPoint(x: 9.29, y: 0), controlPoint1: CGPoint(x: 10, y: 0.33), controlPoint2: CGPoint(x: 9.69, y: 0))
        iconCopy.addCurve(to: CGPoint(x: 8.77, y: 0.23), controlPoint1: CGPoint(x: 9.1, y: 0), controlPoint2: CGPoint(x: 8.91, y: 0.09))
        iconCopy.addLine(to: CGPoint(x: 5, y: 4.21))
        iconCopy.addLine(to: CGPoint(x: 1.23, y: 0.23))
        iconCopy.addCurve(to: CGPoint(x: 0.71, y: 0), controlPoint1: CGPoint(x: 1.09, y: 0.09), controlPoint2: CGPoint(x: 0.91, y: 0))
        iconCopy.addCurve(to: CGPoint(x: 0, y: 0.75), controlPoint1: CGPoint(x: 0.31, y: 0), controlPoint2: CGPoint(x: 0, y: 0.33))
        iconCopy.addCurve(to: CGPoint(x: 0.2, y: 1.28), controlPoint1: CGPoint(x: 0, y: 0.96), controlPoint2: CGPoint(x: 0.07, y: 1.14))
        iconCopy.addLine(to: CGPoint(x: 4.45, y: 5.75))
        iconCopy.addCurve(to: CGPoint(x: 5, y: 6), controlPoint1: CGPoint(x: 4.62, y: 5.92), controlPoint2: CGPoint(x: 4.8, y: 6))
        iconCopy.close()
        context.saveGState()
        context.translateBy(x: 8, y: 3)
        context.rotate(by: CGFloat.pi)
        context.translateBy(x: -5, y: -3)
        color.setFill()
        iconCopy.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawChevronDown(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 16), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 16)

        /// icon
        let icon = UIBezierPath()
        icon.move(to: CGPoint(x: 5, y: 6))
        icon.addCurve(to: CGPoint(x: 5.55, y: 5.75), controlPoint1: CGPoint(x: 5.21, y: 6), controlPoint2: CGPoint(x: 5.4, y: 5.92))
        icon.addLine(to: CGPoint(x: 9.8, y: 1.28))
        icon.addCurve(to: CGPoint(x: 10, y: 0.75), controlPoint1: CGPoint(x: 9.93, y: 1.14), controlPoint2: CGPoint(x: 10, y: 0.96))
        icon.addCurve(to: CGPoint(x: 9.29, y: 0), controlPoint1: CGPoint(x: 10, y: 0.33), controlPoint2: CGPoint(x: 9.69, y: 0))
        icon.addCurve(to: CGPoint(x: 8.77, y: 0.23), controlPoint1: CGPoint(x: 9.1, y: 0), controlPoint2: CGPoint(x: 8.91, y: 0.09))
        icon.addLine(to: CGPoint(x: 5, y: 4.21))
        icon.addLine(to: CGPoint(x: 1.23, y: 0.23))
        icon.addCurve(to: CGPoint(x: 0.71, y: 0), controlPoint1: CGPoint(x: 1.09, y: 0.09), controlPoint2: CGPoint(x: 0.91, y: 0))
        icon.addCurve(to: CGPoint(x: 0, y: 0.75), controlPoint1: CGPoint(x: 0.31, y: 0), controlPoint2: CGPoint(x: 0, y: 0.33))
        icon.addCurve(to: CGPoint(x: 0.2, y: 1.28), controlPoint1: CGPoint(x: 0, y: 0.96), controlPoint2: CGPoint(x: 0.07, y: 1.14))
        icon.addLine(to: CGPoint(x: 4.45, y: 5.75))
        icon.addCurve(to: CGPoint(x: 5, y: 6), controlPoint1: CGPoint(x: 4.62, y: 5.92), controlPoint2: CGPoint(x: 4.8, y: 6))
        icon.close()
        context.saveGState()
        context.translateBy(x: 3, y: 5.5)
        color.setFill()
        icon.fill()
        context.restoreGState()

        context.restoreGState()
    }

    class func drawSearch(color: UIColor = .black, frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 19, height: 19), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 19, y: resizedFrame.height / 19)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 7.71, y: 15.27))
        bezierPath.addCurve(to: CGPoint(x: 12.26, y: 13.78), controlPoint1: CGPoint(x: 9.41, y: 15.27), controlPoint2: CGPoint(x: 10.98, y: 14.71))
        bezierPath.addLine(to: CGPoint(x: 17.22, y: 18.71))
        bezierPath.addCurve(to: CGPoint(x: 17.97, y: 19), controlPoint1: CGPoint(x: 17.43, y: 18.9), controlPoint2: CGPoint(x: 17.7, y: 19))
        bezierPath.addCurve(to: CGPoint(x: 19, y: 17.97), controlPoint1: CGPoint(x: 18.57, y: 19), controlPoint2: CGPoint(x: 19, y: 18.54))
        bezierPath.addCurve(to: CGPoint(x: 18.7, y: 17.24), controlPoint1: CGPoint(x: 19, y: 17.7), controlPoint2: CGPoint(x: 18.91, y: 17.43))
        bezierPath.addLine(to: CGPoint(x: 13.77, y: 12.33))
        bezierPath.addCurve(to: CGPoint(x: 15.4, y: 7.64), controlPoint1: CGPoint(x: 14.8, y: 11.03), controlPoint2: CGPoint(x: 15.4, y: 9.4))
        bezierPath.addCurve(to: CGPoint(x: 7.71, y: 0), controlPoint1: CGPoint(x: 15.4, y: 3.43), controlPoint2: CGPoint(x: 11.95, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 7.64), controlPoint1: CGPoint(x: 3.47, y: 0), controlPoint2: CGPoint(x: 0, y: 3.42))
        bezierPath.addCurve(to: CGPoint(x: 7.71, y: 15.27), controlPoint1: CGPoint(x: 0, y: 11.84), controlPoint2: CGPoint(x: 3.47, y: 15.27))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 7.71, y: 13.8))
        bezierPath.addCurve(to: CGPoint(x: 1.47, y: 7.64), controlPoint1: CGPoint(x: 4.29, y: 13.8), controlPoint2: CGPoint(x: 1.47, y: 11.02))
        bezierPath.addCurve(to: CGPoint(x: 7.71, y: 1.47), controlPoint1: CGPoint(x: 1.47, y: 4.25), controlPoint2: CGPoint(x: 4.29, y: 1.47))
        bezierPath.addCurve(to: CGPoint(x: 13.93, y: 7.64), controlPoint1: CGPoint(x: 11.12, y: 1.47), controlPoint2: CGPoint(x: 13.93, y: 4.25))
        bezierPath.addCurve(to: CGPoint(x: 7.71, y: 13.8), controlPoint1: CGPoint(x: 13.93, y: 11.02), controlPoint2: CGPoint(x: 11.12, y: 13.8))
        bezierPath.close()
        color.setFill()
        bezierPath.fill()

        context.restoreGState()
    }

    // MARK: - Canvas Images

    /// Icons

    class func imageOfBorderStyleRoundedRect() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 16), false, 0)
        IconKit.drawBorderStyleRoundedRect()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfBorderStyleBezel() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 16), false, 0)
        IconKit.drawBorderStyleBezel()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfBorderStyleLine() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 16), false, 0)
        IconKit.drawBorderStyleLine()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfBorderStyleNone() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 16), false, 0)
        IconKit.drawBorderStyleNone()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfTextAlignmentNatural() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawTextAlignmentNatural()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfTextAlignmentJustified() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawTextAlignmentJustified()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfTextAlignmentRight() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawTextAlignmentRight()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfTextAlignmentCenter() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawTextAlignmentCenter()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfAppearanceDark() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawAppearanceDark()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfAppearanceMedium() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawAppearanceMedium()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfSliderHorizontal() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 24), false, 0)
        IconKit.drawSliderHorizontal()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfSetSquareFill() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 24), false, 0)
        IconKit.drawSetSquareFill()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfAppearanceLight() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawAppearanceLight()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfTextAlignmentLeft() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        IconKit.drawTextAlignmentLeft()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfColorGrid() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 32, height: 16), false, 0)
        IconKit.drawColorGrid()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfVerticalAlignmentTop() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 15, height: 11), false, 0)
        IconKit.drawVerticalAlignmentTop()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfVerticalAlignmentCenter() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 15, height: 11), false, 0)
        IconKit.drawVerticalAlignmentCenter()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfVerticalAlignmentBottom() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 15, height: 11), false, 0)
        IconKit.drawVerticalAlignmentBottom()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfVerticalAlignmentFill() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 11, height: 11), false, 0)
        IconKit.drawVerticalAlignmentFill()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfHorizontalAlignmentFill() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 11, height: 11), false, 0)
        IconKit.drawHorizontalAlignmentFill()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfHorizontalAlignmentRight() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 11, height: 15), false, 0)
        IconKit.drawHorizontalAlignmentRight()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfHorizontalAlignmentTrailing() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 11, height: 15), false, 0)
        IconKit.drawHorizontalAlignmentTrailing()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfHorizontalAlignmentCenter() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 11, height: 15), false, 0)
        IconKit.drawHorizontalAlignmentCenter()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfHorizontalAlignmentLeft() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 11, height: 15), false, 0)
        IconKit.drawHorizontalAlignmentLeft()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfHorizontalAlignmentLeading() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 11, height: 15), false, 0)
        IconKit.drawHorizontalAlignmentLeading()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfWifiExlusionMark(_ size: CGSize = CGSize(width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        IconKit.drawWifiExlusionMark()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfEyeSlashFill(_ size: CGSize = CGSize(width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        IconKit.drawEyeSlashFill(frame: CGRect(origin: .zero, size: size), resizing: resizing)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfListBulletIndent(_ size: CGSize = CGSize(width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        IconKit.drawListBulletIndent(frame: CGRect(origin: .zero, size: size), resizing: resizing)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfInfoCircleFill(_ size: CGSize = CGSize(width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        IconKit.drawInfoCircleFill(frame: CGRect(origin: .zero, size: size), resizing: resizing)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfChevronUpDown(_ size: CGSize = CGSize(width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        IconKit.drawChevronUpDown(frame: CGRect(origin: .zero, size: size), resizing: resizing)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfSizeArrowVertical() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 7, height: 9), false, 0)
        IconKit.drawSizeArrowVertical()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfSizeArrowHorizontal() -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 9, height: 7), false, 0)
        IconKit.drawSizeArrowHorizontal()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfChevronRight(_ size: CGSize = CGSize(width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) -> UIImage? {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }

        guard let cgImage = imageOfChevronDown(size, resizing: resizing).cgImage else {
            return nil
        }

        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .left)

        LocalCache.image = image

        return image
    }

    class func imageOfChevronLeft(_ size: CGSize = CGSize(width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) -> UIImage? {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }

        guard let cgImage = imageOfChevronDown(size, resizing: resizing).cgImage else {
            return nil
        }

        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)

        LocalCache.image = image

        return image
    }

    class func imageOfChevronDown(_ size: CGSize = CGSize(width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        IconKit.drawChevronDown(frame: CGRect(origin: .zero, size: size), resizing: resizing)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    class func imageOfSearch(_ size: CGSize = CGSize(width: 16, height: 16), resizing: ResizingBehavior = .aspectFit) -> UIImage {
        enum LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        IconKit.drawSearch(frame: CGRect(origin: .zero, size: size), resizing: resizing)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        LocalCache.image = image
        return image
    }

    // MARK: - Resizing Behavior

    enum ResizingBehavior {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
