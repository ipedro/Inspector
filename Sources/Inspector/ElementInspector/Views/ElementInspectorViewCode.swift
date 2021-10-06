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


// MARK: - ElementInspectorViewCode

final class ElementInspectorViewCode: BaseView {
    var keyboardHeight: CGFloat = .zero {
        didSet {
            scrollView.contentInset = UIEdgeInsets(bottom: keyboardHeight)
        }
    }

    var content: Content? {
        didSet {
            updateContent(from: oldValue, to: content)
        }
    }

    private lazy var scrollView = ScrollingStackView().then {
        $0.contentView.directionalLayoutMargins = .init(bottom: ElementInspector.appearance.horizontalMargins)
        $0.contentView.addArrangedSubviews(elementDescriptionView, separatorView, contentView)
        $0.keyboardDismissMode = .onDrag
        $0.alwaysBounceVertical = true
    }

    private(set) lazy var elementDescriptionView = ViewHierarchyElementDescriptionView().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.elementNameLabel.isSafelyHidden = true
        $0.directionalLayoutMargins = .init(
            top: .zero,
            leading: ElementInspector.appearance.horizontalMargins,
            bottom: ElementInspector.appearance.horizontalMargins,
            trailing: ElementInspector.appearance.horizontalMargins * 2
        )
    }

    private func adjustedContentSize(of scrollView: UIScrollView) -> CGSize {
        return CGSize(
            width: scrollView.contentSize.width + scrollView.adjustedContentInset.left + scrollView.adjustedContentInset.right,
            height: scrollView.contentSize.height + scrollView.adjustedContentInset.top + scrollView.adjustedContentInset.bottom
        )
    }

    var contentSize: CGSize {
        var frameWidth: CGSize {
            CGSize(width: frame.width, height: frame.width )
        }

        switch content?.type {
        case .none:
            return .zero

        case .panelView:
            return adjustedContentSize(of: scrollView)

        case .scrollView:
            if let contentScrollView = content?.view as? UIScrollView {
                return adjustedContentSize(of: contentScrollView)
            }
            else {
                return frameWidth
            }

        case .backgroundView:
            return frameWidth
        }
    }

    private(set) lazy var separatorView = SeparatorView(style: .hard)

    private func updateContent(from oldValue: Content?, to newContent: Content?) {
        oldValue?.view.removeFromSuperview()

        let hostScrollView: UIScrollView

        switch newContent?.type {
        case .none:
            hostScrollView = scrollView
            separatorView.isSafelyHidden = true

        case .backgroundView:
            hostScrollView = scrollView
            separatorView.isSafelyHidden = true

            if let backgroundView = newContent?.view {
                backgroundView.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(backgroundView)

                [backgroundView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
                 backgroundView.leadingAnchor.constraint(equalTo: scrollView.readableContentGuide.leadingAnchor),
                 backgroundView.trailingAnchor.constraint(equalTo: scrollView.readableContentGuide.trailingAnchor),
                 backgroundView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                ]
                .forEach { $0.isActive = true}
            }

        case .panelView:
            hostScrollView = scrollView
            separatorView.isSafelyHidden = false

            guard let content = newContent?.view else {
                assertionFailure("Should never happend")
                return
            }

            contentView.installView(content, priority: .required)

        case .scrollView:
            separatorView.isSafelyHidden = true

            guard let contentScrollView = newContent?.view as? UIScrollView else {
                assertionFailure("Should never happend")
                return
            }

            hostScrollView = contentScrollView
        }

        if hostScrollView != scrollView {
            scrollView.removeFromSuperview()
        }

        installView(hostScrollView, position: .behind, priority: .required)
    }

    func setContentAnimated(_ content: Content, animateAlongSideTransition animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        switch content.type {
        case .panelView:
            content.view.alpha = 0
            content.view.transform = ElementInspector.appearance.panelInitialTransform
        case .backgroundView:
            content.view.alpha = 0

        case .scrollView:
            break
        }

        self.content = content

        animate(
            withDuration: .veryLong,
            delay: .veryShort / 2,
            options: [.layoutSubviews, .beginFromCurrentState],
            animations: {
                content.view.alpha = 1
                content.view.transform = .identity

                animations?()
            },
            completion: { finished in
                completion?(finished)
            }
        )
    }

}
