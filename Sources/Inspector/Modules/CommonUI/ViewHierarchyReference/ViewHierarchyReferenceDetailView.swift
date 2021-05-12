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

protocol ViewHierarchyReferenceDetailViewModelProtocol {
    var thumbnailImage: UIImage? { get }
    
    var title: String { get }
    
    var titleFont: UIFont { get }
    
    var subtitle: String { get }
    
    var isContainer: Bool { get }
    
    var isCollapsed: Bool { get set }
    
    var isChevronHidden: Bool { get }
    
    var isHidden: Bool { get }
    
    var relativeDepth: Int { get }
}

final class ViewHierarchyReferenceDetailView: BaseView {
    
    var viewModel: ViewHierarchyReferenceDetailViewModelProtocol? {
        didSet {
            
            // Name
            
            elementNameLabel.text = viewModel?.title

            elementNameLabel.font = viewModel?.titleFont
            
            thumbnailImageView.image = viewModel?.thumbnailImage
            
            // Collapsed

            isCollapsed = viewModel?.isCollapsed == true
            
            chevronDownIcon.isSafelyHidden = viewModel?.isChevronHidden ?? true

            // Description

            descriptionLabel.text = viewModel?.subtitle

            // Containers Insets

            let relativeDepth = CGFloat(viewModel?.relativeDepth ?? 0)
            let offset = (ElementInspector.appearance.verticalMargins * relativeDepth)
            
            var directionalLayoutMargins = contentView.directionalLayoutMargins
            directionalLayoutMargins.leading = offset
            
            contentView.directionalLayoutMargins = directionalLayoutMargins
        }
    }
    
    var isCollapsed = false {
        didSet {
            chevronDownIcon.transform = isCollapsed ? .init(rotationAngle: -(.pi / 2)) : .identity
        }
    }
    
    func toggleCollapse(animated: Bool) {
        guard animated else {
            isCollapsed.toggle()
            return
        }
        
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak self] in
                
                self?.isCollapsed.toggle()
                
            },
            completion: nil
        )
    }
    
    private(set) lazy var elementNameLabel = UILabel(
        .textColor(ElementInspector.appearance.textColor),
        .numberOfLines(1),
        .adjustsFontSizeToFitWidth(true),
        .minimumScaleFactor(0.75),
        .allowsDefaultTighteningForTruncation(true),
        .huggingPriority(.defaultHigh, for: .vertical)
    )
    
    private(set) lazy var descriptionLabel = UILabel(
        .textStyle(.caption2),
        .textColor(ElementInspector.appearance.secondaryTextColor),
        .numberOfLines(.zero),
        .preferredMaxLayoutWidth(200),
        .compressionResistance(.defaultHigh, for: .vertical)
    )
    
    private(set) lazy var chevronDownIcon = Icon.chevronDownIcon()
    
    private(set) lazy var thumbnailImageView = UIImageView(
        .contentMode(.center),
        .tintColor(ElementInspector.appearance.textColor),
        .backgroundColor(ElementInspector.appearance.quaternaryTextColor),
        .layerOptions(.cornerRadius(ElementInspector.appearance.verticalMargins / 2)),
        .clipsToBounds(true),
        .layoutCompression(
            .huggingPriority(.required, for: .horizontal),
            .huggingPriority(.required, for: .vertical)
        )
    )
    
    private(set) lazy var textStackView = UIStackView.vertical(
        .arrangedSubviews(
            elementNameLabel,
            descriptionLabel
        ),
        .spacing(ElementInspector.appearance.verticalMargins / 2)
    )
    
    override func setup() {
        super.setup()
        
        contentView.axis = .horizontal
        contentView.spacing = ElementInspector.appearance.verticalMargins
        contentView.alignment = .center
        
        contentView.addArrangedSubviews(thumbnailImageView, textStackView)
        
        installView(
            contentView,
            .insets(ElementInspector.appearance.directionalInsets),
            priority: .required
        )
    
        setupChevronDownIcon()
    }
    
    private func setupChevronDownIcon() {
        contentView.addSubview(chevronDownIcon)
        
        chevronDownIcon.centerYAnchor.constraint(equalTo: elementNameLabel.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(
            equalTo: elementNameLabel.leadingAnchor,
            constant: -(ElementInspector.appearance.verticalMargins / 3)
        ).isActive = true
        
    }
    
}