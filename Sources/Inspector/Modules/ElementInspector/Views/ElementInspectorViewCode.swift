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
    private(set) lazy var segmentedControl = UISegmentedControl.segmentedControlStyle()

    private(set) lazy var referenceSummaryView = ViewHierarchyReferenceSummaryView().then {
        $0.setContentHuggingPriority(.required, for: .vertical)
    }

    private(set) lazy var separatorView = SeparatorView(style: .medium)

    private lazy var referenceSummaryHeightConstraint = referenceSummaryView.heightAnchor.constraint(equalToConstant: .zero).then {
        $0.priority = .defaultHigh
        $0.isActive = true
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

    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    private(set) lazy var emptyLabel = SectionHeader(
        title: "No Element Inspector",
        titleFont: .body,
        margins: ElementInspector.appearance.directionalInsets
    ).then {
        $0.titleAlignment = .center
        $0.alpha = 0.5
    }

    private lazy var containerStackView = UIStackView.vertical().then {
        $0.addArrangedSubviews(referenceSummaryView, separatorView, contentView)
    }
    
    override func setup() {
        super.setup()

        backgroundColor = colorStyle.backgroundColor

        contentView.installView(emptyLabel, .margins(.zero), position: .behind)
        
        installView(containerStackView, priority: .required)

        containerStackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
