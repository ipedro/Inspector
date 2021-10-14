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
    var draggableAreaAdjustedContentInset: UIEdgeInsets { get }
    var draggableView: UIView { get }
    var isDragging: Bool { get set }
}

extension DraggableViewProtocol {
    func dragView(with gesture: UIPanGestureRecognizer) {
        guard adjustedDraggableAreaFrame().isEmpty == false else {
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
}

private extension DraggableViewProtocol {
    var draggableAreaFrame: CGRect {
        CGRect(
            x: draggableAreaLayoutGuide.layoutFrame.minX + draggableAreaAdjustedContentInset.left,
            y: draggableAreaLayoutGuide.layoutFrame.minY + draggableAreaAdjustedContentInset.top,
            width: draggableAreaLayoutGuide.layoutFrame.width - draggableAreaAdjustedContentInset.horizontalInsets,
            height: draggableAreaLayoutGuide.layoutFrame.height - draggableAreaAdjustedContentInset.verticalInsets
        )
    }

    var draggableViewFrame: CGRect {
        draggableView.convert(draggableView.bounds, to: self)
    }

    func adjustedDraggableAreaFrame() -> CGRect {
        let halfWidth = draggableView.frame.width / 2
        let halfHeight = draggableView.frame.height / 2
        let frame = draggableAreaFrame.insetBy(dx: halfWidth, dy: halfHeight)

        return frame
    }

    func centerInsideDraggableArea(from location: CGPoint) -> CGPoint {
        let containerFrame = adjustedDraggableAreaFrame()

        let ratioX = min(1, location.x / containerFrame.maxX)
        let ratioY = min(1, location.y / containerFrame.maxY)

        let finalX = max(containerFrame.minX, containerFrame.maxX * ratioX)
        let finalY = max(containerFrame.minY, containerFrame.maxY * ratioY)

        let point = CGPoint(x: finalX, y: finalY)

        return point
    }

    func finalizeDrag() {
        let center = centerInsideDraggableArea(from: draggableView.center)

        animate(withDuration: .long, options: [.beginFromCurrentState, .curveEaseIn]) {
            self.draggableView.center = center
        }
    }
}
