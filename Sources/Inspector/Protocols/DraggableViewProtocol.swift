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

protocol DraggableViewProtocol: UIView {
    var draggableAreaLayoutGuide: UILayoutGuide { get }
    var draggableView: UIView { get }
    var isDragging: Bool { get set }
}

extension DraggableViewProtocol {
    func dragView(with gesture: UIPanGestureRecognizer) {
        let layoutFrame = draggableAreaLayoutGuide.layoutFrame

        guard layoutFrame.width + layoutFrame.height > (draggableView.frame.size.width + draggableView.frame.size.height) * 2 else {
            return
        }

        let location = gesture.location(in: self)

        draggableView.center = location

        guard gesture.state == .ended else {
            isDragging = true
            return
        }

        isDragging = false

        let finalX: CGFloat
        let finalY: CGFloat

        let sourceHitBounds = draggableView.convert(
            draggableView.bounds.insetBy(dx: -draggableView.bounds.width / 3, dy: -draggableView.bounds.height / 3), to: self)

        if (sourceHitBounds.minX...sourceHitBounds.maxX).contains(layoutFrame.midX) {
            finalX = layoutFrame.midX
        }
        else if draggableView.frame.midX >= layoutFrame.width / 2 {
            finalX = max(0, layoutFrame.maxX - (draggableView.frame.width / 2))
        }
        else {
            finalX = layoutFrame.minX + draggableView.frame.width / 2
        }

        if (sourceHitBounds.minY...sourceHitBounds.maxY).contains(layoutFrame.midY) {
            finalY = layoutFrame.midY
        }
        else if draggableView.frame.midY >= layoutFrame.height / 2 {
            finalY = max(0, layoutFrame.maxY - (draggableView.frame.height / 2))
        }
        else {
            finalY = layoutFrame.minY + draggableView.frame.height / 2
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: [.beginFromCurrentState, .curveEaseIn]
        ) {
            self.draggableView.center = CGPoint(x: finalX, y: finalY)
        }
    }
}
