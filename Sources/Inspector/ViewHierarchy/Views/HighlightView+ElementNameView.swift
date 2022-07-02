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

protocol ElementNameViewDisplayerProtocol: UIView {
    var elementFrame: CGRect { get }
}

final class ElementNameView: LayerViewComponent {
    // MARK: - Properties

    enum DisplayMode: Swift.CaseIterable, MenuContentProtocol {
        case auto, iconAndText, text, icon

        var title: String {
            switch self {
            case .auto: return "Automatic"
            case .iconAndText: return "Icon And Text"
            case .text: return "Text"
            case .icon: return "Icon"
            }
        }

        var image: UIImage? { .none }

        static func allCases(for element: ViewHierarchyElementReference) -> [DisplayMode] { allCases }
    }

    weak var displayer: ElementNameViewDisplayerProtocol?

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        displayer = newSuperview as? ElementNameViewDisplayerProtocol
    }

    override var tintColor: UIColor! {
        didSet {
            updateColors()
        }
    }

    var displayMode: DisplayMode = .auto {
        didSet {
            animate {
                self.updateContent()
            }
        }
    }

    private let cornerRadius: CGFloat = 8

    private let contentColor: UIColor = .white

    // MARK: - Components

    private(set) lazy var label = UILabel().then {
        $0.font = UIFont(name: "MuktaMahee-Regular", size: 11)
        $0.textColor = contentColor
        $0.textAlignment = .center
    }

    private(set) lazy var imageView = UIImageView().then {
        $0.tintColor = contentColor
    }

    private(set) lazy var roundedPillView = LayerViewComponent().then {
        $0.clipsToBounds = true
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.layer.borderWidth = 1 / UIScreen.main.scale

        $0.contentView.addArrangedSubviews(imageView, label)
        $0.contentView.alignment = .center
        $0.contentView.axis = .horizontal
        $0.contentView.spacing = cornerRadius / 2

        $0.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.contentView.layer.shadowOpacity = 1
        $0.contentView.layer.shadowRadius = 1

        enableRasterization()
    }

    override func setup() {
        super.setup()

        resetShadow()

        installView(roundedPillView, .autoResizingMask)

        updateColors()

        enableRasterization()
    }

    func resetShadow() {
        layer.shadowOffset = .init(width: .zero, height: 1)
        layer.shadowOpacity = Float(colorStyle.disabledAlpha * 2)
        layer.shadowRadius = 1
    }

    @objc
    private func updateColors() {
        let darkerTintColor = tintColor.darker(amount: 2 / 3)

        layer.shadowColor = darkerTintColor.cgColor
        roundedPillView.contentView.layer.shadowColor = darkerTintColor.cgColor
        roundedPillView.layer.borderColor = darkerTintColor.cgColor
        roundedPillView.backgroundColor = tintColor
    }

    private var displayerFrame: CGRect { displayer?.frame ?? bounds }

    @objc
    private func updateContent() {
        switch displayMode {
        case .auto:
            // ⚠️ important to unhide subviews before calculating layout size below
            label.isHidden = false
            imageView.isHidden = imageView.image == nil
            roundedPillView.layoutIfNeeded()
            label.isHidden = {
                let intrinsicSize = systemLayoutSizeFitting(displayerFrame.size)
                return intrinsicSize.width > displayerFrame.width * 1.3
            }()

        case .iconAndText:
            label.isHidden = false
            imageView.isHidden = false

        case .text:
            label.isHidden = false
            imageView.isHidden = true

        case .icon:
            label.isHidden = true
            imageView.isHidden = false
        }

        label.alpha = label.isHidden ? 0 : 1
        imageView.alpha = imageView.isHidden ? 0 : 1
        roundedPillView.contentView.directionalLayoutMargins = .init(
            top: 1,
            leading: imageView.isHidden ? 6 : 3,
            bottom: 1,
            trailing: label.isHidden ? 3 : 6
        )
    }

    private var isFirstLayoutSubviews = true

    override func layoutSubviews() {
        super.layoutSubviews()

        roundedPillView.layer.cornerRadius = min(cornerRadius, roundedPillView.frame.height / 2)

        guard isFirstLayoutSubviews else {
            return
        }

        isFirstLayoutSubviews = false

        updateContent()
    }
}
