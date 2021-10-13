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
    var draggableViewCenterOffset: CGPoint { get }
    var isDragging: Bool { get set }
}

extension DraggableViewProtocol {
    private var draggableFrame: CGRect { draggableAreaLayoutGuide.layoutFrame }

    func dragView(with gesture: UIPanGestureRecognizer) {
        guard draggableFrame.width + draggableFrame.height > (draggableView.frame.size.width + draggableView.frame.size.height) * 2 else {
            isDragging = false
            return
        }

        let location = gesture.location(in: self)
        draggableView.center = location

        switch gesture.state {
        case .possible, .began, .changed:
            isDragging = true

        case .cancelled, .failed:
            isDragging = false

        case .ended:
            isDragging = false
            finalizeDrag()

        @unknown default:
            return
        }
    }

    func finalizeDrag() {
        let sourceHitBounds = draggableView.convert(
            draggableView.bounds.insetBy(
                dx: -draggableView.bounds.width / 5,
                dy: -draggableView.bounds.height / 5
            ), to: self
        )

        let finalX: CGFloat = {
            if (sourceHitBounds.minX...sourceHitBounds.maxX).contains(draggableFrame.midX) {
                return draggableFrame.midX
            }
            else if draggableView.frame.midX >= draggableFrame.width / 2 {
                return max(0, draggableFrame.maxX - (draggableView.frame.width / 2))
            }
            else {
                return draggableFrame.minX + draggableView.frame.width / 2
            }
        }()

        let finalY: CGFloat = {
            if (sourceHitBounds.minY...sourceHitBounds.maxY).contains(draggableFrame.midY) {
                return draggableFrame.midY
            }
            else if draggableView.frame.midY >= draggableFrame.height / 2 {
                return max(0, draggableFrame.maxY - (draggableView.frame.height / 2))
            }
            else {
                return draggableFrame.minY + draggableView.frame.height / 2
            }
        }()

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
