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

protocol HierarchyInspectorReferenceSummaryCellViewModelProtocol {
    var title: String? { get }
    var isEnabled: Bool { get }
    var subtitle: String? { get }
    var image: UIImage? { get }
    var depth: Int { get }
    var element: ViewHierarchyElementReference { get }
}

final class HierarchyInspectorReferenceSummaryTableViewCell: HierarchyInspectorTableViewCell {
    var viewModel: HierarchyInspectorReferenceSummaryCellViewModelProtocol? {
        didSet {
            textLabel?.text = viewModel?.title
            detailTextLabel?.text = viewModel?.subtitle
            imageView?.image = viewModel?.image

            let depth = CGFloat(viewModel?.depth ?? 0)
            var margins = defaultLayoutMargins
            margins.leading += depth * 5

            directionalLayoutMargins = margins
            separatorInset = UIEdgeInsets(left: margins.leading, right: defaultLayoutMargins.trailing)

            contentView.alpha = viewModel?.isEnabled == true ? 1 : colorStyle.disabledAlpha
            selectionStyle = viewModel?.isEnabled == true ? .default : .none
        }
    }

    override func setup() {
        super.setup()

        textLabel?.font = .preferredFont(forTextStyle: .footnote).bold()
        textLabel?.numberOfLines = 2

        detailTextLabel?.numberOfLines = 4

        imageView?.tintColor = colorStyle.textColor
        imageView?.clipsToBounds = true
        imageView?.backgroundColor = colorStyle.quaternaryTextColor
        imageView?.contentMode = .center

        imageView?.layer.cornerRadius = elementInspectorAppearance.verticalMargins / 2
        imageView?.layer.cornerCurve = .continuous

        installView(contentView)
    }
}
