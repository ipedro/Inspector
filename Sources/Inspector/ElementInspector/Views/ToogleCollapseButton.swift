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

final class ToogleCollapseButton: BaseControl {
    private lazy var imageView = UIImageView(image: .expandSymbol, highlightedImage: .collapseSymbol).then {
        $0.widthAnchor.constraint(equalToConstant: CGSize.regularIconSize.width).isActive = true
        $0.heightAnchor.constraint(equalToConstant: CGSize.regularIconSize.height).isActive = true
    }

    private lazy var activityIndicatorView = UIActivityIndicatorView().then {
        installView($0, .centerXY)
        $0.color = colorStyle.tertiaryTextColor
        $0.hidesWhenStopped = true
    }

    private func startLoading() {
        isEnabled = false
        imageView.alpha = 0
        activityIndicatorView.startAnimating()
    }

    private func stopLoading() {
        isEnabled = true
        imageView.alpha = 1
        activityIndicatorView.stopAnimating()
    }

    var collapseState: ElementInspectorFormPanelCollapseState? {
        didSet {
            switch collapseState {
            case .none:
                startLoading()

            case .allExpanded:
                stopLoading()
                isSelected = true

            case .allCollapsed:
                stopLoading()
                isSelected = false

            case .mixed:
                stopLoading()
                isSelected = false

            case .firstExpanded:
                stopLoading()
                isSelected = false
            }
        }
    }

    override func setup() {
        super.setup()

        tintColor = colorStyle.secondaryTextColor

        installView(imageView)

        updateViews()

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    private func updateViews() {
        if state == .selected {
            imageView.isHighlighted = true
            imageView.transform = .init(rotationAngle: .pi / 2)
        }
        else {
            imageView.isHighlighted = false
            imageView.transform = .identity
        }
    }

    override func stateDidChange(from oldState: UIControl.State, to newState: UIControl.State) {
        animate(withDuration: .long) {
            self.updateViews()
        }
    }
}

