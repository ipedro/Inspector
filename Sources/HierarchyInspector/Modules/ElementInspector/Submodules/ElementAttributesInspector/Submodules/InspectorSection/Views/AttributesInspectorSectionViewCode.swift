//
//  AttributesInspectorSectionViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol AttributesInspectorSectionViewCodeDelegate: AnyObject {
    
    func attributesInspectorSectionViewCode(_ section: AttributesInspectorSectionViewCode, didToggle isCollapsed: Bool)
    
}

final class AttributesInspectorSectionViewCode: BaseView {
    weak var delegate: AttributesInspectorSectionViewCodeDelegate?
    
    private(set) lazy var inputContainerView = UIStackView(axis: .vertical)
    
    private lazy var topSeparatorView = SeparatorView(thickness: 1)
    
    private(set) lazy var sectionHeader = SectionHeader(
        .callout,
        text: nil,
        withTraits: .traitBold,
        margins: .margins(
            horizontal: .zero,
            vertical: ElementInspector.appearance.verticalMargins / 2
        )
    )
    
    var isCollapsed: Bool = false {
        didSet {
            hideContent(isCollapsed)
        }
    }
    
    private lazy var toggleControl = UIControl().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.addTarget(self, action: #selector(tapHeader), for: .touchUpInside)
    }
    
    private lazy var chevronDownIcon = Icon.chevronDownIcon()
    
    override func setup() {
        super.setup()
        
        hideContent(isCollapsed)
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        contentView.directionalLayoutMargins = ElementInspector.appearance.margins
        
        contentView.addArrangedSubview(sectionHeader)
        
        contentView.addArrangedSubview(inputContainerView)
        
        contentView.setCustomSpacing(
            ElementInspector.appearance.verticalMargins,
            after: sectionHeader
        )
        
        installSeparator()
        
        installIcon()
        
        installHeaderControl()
    }
    
    private func installHeaderControl() {
        contentView.addSubview(toggleControl)
        
        toggleControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toggleControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        toggleControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toggleControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
    }
    
    private func installIcon() {
        contentView.addSubview(chevronDownIcon)
        
        chevronDownIcon.centerYAnchor.constraint(equalTo: sectionHeader.centerYAnchor).isActive = true

        chevronDownIcon.trailingAnchor.constraint(
            equalTo: sectionHeader.leadingAnchor,
            constant: -(ElementInspector.appearance.verticalMargins / 3)
        ).isActive = true
    }
    
    private func installSeparator() {
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topSeparatorView)
    
        topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    @objc private func tapHeader() {
        delegate?.attributesInspectorSectionViewCode(self, didToggle: isCollapsed)
    }
    
    private func hideContent(_ hide: Bool) {
        inputContainerView.clipsToBounds  = hide
        inputContainerView.isSafelyHidden = hide
        inputContainerView.alpha          = hide ? 0 : 1
        chevronDownIcon.transform         = hide ? CGAffineTransform(rotationAngle: -(.pi / 2)) : .identity
    }
}
