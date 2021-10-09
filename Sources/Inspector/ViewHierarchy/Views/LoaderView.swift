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

final class LoaderView: LayerViewComponent {
    // MARK: - Components

    private lazy var activityIndicator = UIActivityIndicatorView(style: .whiteLarge).then {
        $0.hidesWhenStopped = true
        $0.startAnimating()
    }

    private lazy var checkmarkLabel = UILabel(
        .text("✓"),
        .adjustsFontSizeToFitWidth(true),
        .font(.systemFont(ofSize: 32, weight: .semibold)),
        .textColor(.white),
        .textAlignment(.center),
        .viewOptions(.isHidden(true))
    )

    private(set) lazy var highlightView = HighlightView(
        frame: bounds,
        name: elementName,
        colorScheme: colorScheme,
        element: ViewHierarchyElement(with: self, iconProvider: .default)
    ).then {
        $0.verticalAlignmentOffset = activityIndicator.frame.height * 2 / 3
    }

    let colorScheme: ViewHierarchyColorScheme

    override var accessibilityIdentifier: String? {
        didSet {
            if let name = accessibilityIdentifier {
                highlightView.name = name
            }
        }
    }

    init(colorScheme: ViewHierarchyColorScheme, frame: CGRect = .zero) {
        self.colorScheme = colorScheme
        super.init(frame: frame)
    }

    // MARK: - Setup

    override func setup() {
        super.setup()

        installView(checkmarkLabel, .centerXY)

        installView(activityIndicator, .spacing(all: 8))

        installView(highlightView, .autoResizingMask)

        addInspectorViews()

        checkmarkLabel.widthAnchor.constraint(equalTo: activityIndicator.widthAnchor).isActive = true

        checkmarkLabel.heightAnchor.constraint(equalTo: activityIndicator.heightAnchor).isActive = true
    }

    func addInspectorViews() {
        for element in subviews where element.canHostInspectorView {
            element.layer.cornerRadius = layer.cornerRadius / 2

            let inspectorView = WireframeView(
                frame: element.bounds,
                element: ViewHierarchyElement(with: element, iconProvider: .default),
                color: .white
            )

            element.installView(inspectorView, .autoResizingMask, position: .inFront)
        }

        installView(highlightView, .autoResizingMask)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = colorScheme.value(for: self)

        highlightView.labelWidthConstraint = nil

        layer.cornerRadius = frame.height / .pi
    }

    func done() {
        activityIndicator.stopAnimating()

        checkmarkLabel.isSafelyHidden = false
    }

    func prepareForReuse() {
        activityIndicator.startAnimating()

        checkmarkLabel.isSafelyHidden = true

        alpha = 1
    }
}
