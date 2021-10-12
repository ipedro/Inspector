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
        var title: String {
            switch self {
            case .auto:
                return "Automatic"
            case .iconAndText:
                return "Icon And Text"
            case .text:
                return "Text"
            case .icon:
                return "Icon"
            }
        }

        var image: UIImage? {
            switch self {
            case .auto:
                return nil
            case .iconAndText:
                return nil
            case .text:
                return nil
            case .icon:
                return nil
            }
        }

        static func allCases(for element: ViewHierarchyElement) -> [DisplayMode] {
            allCases
        }

        case auto, iconAndText, text, icon
    }


    weak var displayer: ElementNameViewDisplayerProtocol?

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        displayer = newSuperview as? ElementNameViewDisplayerProtocol
    }

    override var tintColor: UIColor! {
        didSet {
            let shadowColor = tintColor.darker(amount: 0.98).cgColor

            layer.shadowColor = shadowColor

            roundedPillView.contentView.layer.shadowColor = shadowColor
            roundedPillView.backgroundColor = tintColor
        }
    }

    var displayMode: DisplayMode = .auto {
        didSet {
            animate {
                self.updateViews()
            }
        }
    }

    // MARK: - Components

    private(set) lazy var label = UILabel().then {
        $0.font = UIFont(name: "MuktaMahee-Regular", size: 12)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private(set) lazy var imageView = UIImageView().then {
        $0.tintColor = .white
        $0.clipsToBounds = true
    }

    private(set) lazy var roundedPillView = LayerViewComponent().then {
        $0.backgroundColor = tintColor
        $0.contentView.addArrangedSubviews(imageView, label, UIView())
        $0.contentView.spacing = 2
        $0.contentView.alignment = .center
        $0.contentView.axis = .horizontal
        $0.contentView.directionalLayoutMargins = .init(horizontal: 2, vertical: 1)
        $0.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.contentView.layer.shadowColor = layer.shadowColor
        $0.contentView.layer.shadowRadius = 3
        $0.contentView.layer.shadowOpacity = 1
        $0.layer.cornerRadius = 7

        $0.contentView.setCustomSpacing(4, after: label)
    }

    override func setup() {
        super.setup()

        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        installView(roundedPillView, .autoResizingMask)
    }

    private var isFirstLayoutSubviews = true

    @objc
    private func updateViews() {
        switch displayMode {
        case .auto:
            // ⚠️ important to unhide subviews before calculating layout size below
            label.isHidden = false
            imageView.isHidden = imageView.image == nil

            let frame = displayer?.frame ?? bounds
            let size = systemLayoutSizeFitting(frame.size)

            label.isHidden = size.width > frame.width * 1.3

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
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard isFirstLayoutSubviews else {
            return debounce(#selector(updateViews), delay: .veryShort, object: nil)
        }

        isFirstLayoutSubviews = false

        alpha = 0
        transform = .init(scaleX: .zero, y: .zero)

        updateViews()

        animate(
            withDuration: .random(in: .veryShort ... .average),
            delay: .random(in: .average ... .veryLong),
            damping: 0.7
        ) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}
