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

final class ElementInspectorViewCode: BaseView {
    var keyboardHeight: CGFloat = .zero {
        didSet {
            scrollView.contentInset = UIEdgeInsets(bottom: keyboardHeight)
        }
    }

    enum Style {
        case scrollView, `default`
    }

    var containerStyle: Style = .default {
        didSet {
            switch containerStyle {
            case .scrollView:
                scrollView.contentOffset = CGPoint(x: .zero, y: -scrollView.adjustedContentInset.top)
                scrollView.installView(containerStackView, priority: .required)
                installView(scrollView, priority: .required)

            case .default:
                scrollView.removeFromSuperview()
                installView(containerStackView, priority: .required)
            }

            containerStackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
    }
    
    private(set) lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.keyboardDismissMode = .onDrag
        $0.delaysContentTouches = false
    }

    private(set) lazy var segmentedControl = UISegmentedControl.segmentedControlStyle()

    private(set) lazy var referenceSummaryView = ViewHierarchyReferenceSummaryView().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private(set) lazy var separatorView = SeparatorView(style: .medium)

    private lazy var referenceSummaryHeightConstraint = referenceSummaryView.heightAnchor.constraint(equalToConstant: .zero).then {
        $0.isActive = true
    }

    private(set) lazy var dismissBarButtonItem: UIBarButtonItem = {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        } else {
            return UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        }
    }()

    private(set) lazy var emptyLabel = SectionHeader(
        title: "No Element Inspector",
        titleFont: .body,
        margins: ElementInspector.appearance.directionalInsets
    ).then {
        contentView.installView($0, position: .behind)
        $0.titleAlignment = .center
        $0.alpha = 0.5
    }

    private(set) lazy var activityIndicator = UIActivityIndicatorView().then {
        $0.color = colorStyle.secondaryTextColor
        $0.hidesWhenStopped = true

        contentView.installView($0, .centerXY, position: .behind)

        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            $0.style = .large
        }
        else {
            $0.style = .whiteLarge
        }
        #else
        $0.style = .whiteLarge
        #endif
    }

    private lazy var containerStackView = UIStackView.vertical().then {
        $0.directionalLayoutMargins = NSDirectionalEdgeInsets(bottom: ElementInspector.appearance.horizontalMargins)
        $0.addArrangedSubviews(referenceSummaryView, separatorView, contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = referenceSummaryView.systemLayoutSizeFitting(
            frame.size,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        guard size.height != referenceSummaryHeightConstraint.constant else { return }

        DispatchQueue.main.async {
            self.referenceSummaryHeightConstraint.constant = size.height
            self.layoutIfNeeded()
        }
    }

    override func setup() {
        super.setup()

        backgroundColor = colorStyle.backgroundColor

        scrollView.installView(containerStackView, priority: .required)

        installView(scrollView, priority: .required)

        containerStackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
