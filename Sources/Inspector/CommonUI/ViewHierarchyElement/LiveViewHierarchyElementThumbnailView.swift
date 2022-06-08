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

    deinit {
        stopLiveUpdatingSnapshot()
    }

    private var displayLink: CADisplayLink? {
        didSet {
            if let oldLink = oldValue {
                oldLink.invalidate()
            }
            if let newLink = displayLink {
                newLink.preferredFramesPerSecond = 30
                newLink.add(to: .current, forMode: .common)
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview?.window == nil {
            stopLiveUpdatingSnapshot()
        }
        else {
            startLiveUpdatingSnapshot()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard let window = window else {
            hoverGestureRecognizer.isEnabled = false
            return
        }

        window.addGestureRecognizer(hoverGestureRecognizer)
        hoverGestureRecognizer.isEnabled = true

        hoverGestureRecognizer.isEnabled = ProcessInfo().isiOSAppOnMac == false

        startLiveUpdatingSnapshot()
    }

    @objc
    func startLiveUpdatingSnapshot() {
        debounce(#selector(makeDisplayLinkIfNeeded), delay: .average)
    }

    @objc
    func makeDisplayLinkIfNeeded() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }

    @objc
    func stopLiveUpdatingSnapshot() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(makeDisplayLinkIfNeeded),
            object: nil
        )

        displayLink = nil
    }

    @objc
    func refresh() {
        guard element.underlyingView?.isAssociatedToWindow == true else {
            return stopLiveUpdatingSnapshot()
        }

        if backgroundStyle.color != backgroundColor {
            backgroundColor = backgroundStyle.color
        }

        if !isHidden, superview?.isHidden == false {
            updateViews(afterScreenUpdates: false)
        }
    }

    private lazy var hoverGestureRecognizer = UIHoverGestureRecognizer(
        target: self,
        action: #selector(hovering(_:))
    )

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
