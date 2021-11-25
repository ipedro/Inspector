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

final class LiveViewHierarchyElementThumbnailView: ViewHierarchyElementThumbnailView {
    override var isHidden: Bool {
        didSet {
            if isHidden {
                stopLiveUpdatingSnapshot()
            }
            else {
                startLiveUpdatingSnapshot()
            }
        }
    }

    private var displayLink: CADisplayLink? {
        didSet {
            if let oldLink = oldValue {
                oldLink.invalidate()
            }

            if let newLink = displayLink {
                newLink.add(to: .current, forMode: .default)
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard superview?.window != nil else {
            return stopLiveUpdatingSnapshot()
        }

        startLiveUpdatingSnapshot()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard let window = window else {
            if #available(iOS 13.0, *) {
                hoverGestureRecognizer.isEnabled = false
            }

            return stopLiveUpdatingSnapshot()
        }

        if #available(iOS 13.0, *) {
            window.addGestureRecognizer(hoverGestureRecognizer)
            hoverGestureRecognizer.isEnabled = true
        }

        if #available(iOS 14.0, *) {
            hoverGestureRecognizer.isEnabled = ProcessInfo().isiOSAppOnMac == false
        }

        startLiveUpdatingSnapshot()
    }

    @objc
    func startLiveUpdatingSnapshot() {
        debounce(#selector(makeDisplayLink), delay: .average)
    }

    @objc
    func makeDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }

    @objc
    func stopLiveUpdatingSnapshot() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(makeDisplayLink),
            object: nil
        )

        displayLink = nil
    }

    @objc
    func refresh() {
        guard element.underlyingView?.inWindow == true else {
            return stopLiveUpdatingSnapshot()
        }

        if backgroundStyle.color != backgroundColor {
            backgroundColor = backgroundStyle.color
        }

        if !isHidden, superview?.isHidden == false {
            updateViews(afterScreenUpdates: false)
        }
    }

    @available(iOS 13.0, *)
    private lazy var hoverGestureRecognizer = UIHoverGestureRecognizer(
        target: self,
        action: #selector(hovering(_:))
    )

    @available(iOS 13.0, *)
    @objc
    func hovering(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            stopLiveUpdatingSnapshot()

        case .ended, .cancelled:
            startLiveUpdatingSnapshot()

        default:
            break
        }
    }
}
