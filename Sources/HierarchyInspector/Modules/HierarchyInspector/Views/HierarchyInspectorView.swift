//
//  HierarchyInspectorView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.04.21.
//

import UIKit

protocol HierarchyInspectorViewDelegate: AnyObject {
    func hierarchyInspectorViewDidTapOutside(_ view: HierarchyInspectorView)
}

final class HierarchyInspectorView: BaseView {
    
    var verticalMargin: CGFloat { 30 }
    
    var horizontalMargin: CGFloat { verticalMargin / 2 }
    
    var keyboardFrame: CGRect? {
        didSet {
            let visibleHeight: CGFloat = {
                guard let keyboardFrame = keyboardFrame else {
                    return .zero
                }
                
                return frame.height - safeAreaInsets.bottom - keyboardFrame.origin.y
            }()
            
            bottomAnchorConstraint.constant = (visibleHeight + verticalMargin) * -1
        }
    }
    
    weak var delegate: HierarchyInspectorViewDelegate?
    
    private(set) lazy var searchView = HierarchyInspectorSearchView()
    
    private(set) lazy var tableView = KeyboardTableView().then {
        $0.indicatorStyle = .white
        $0.backgroundColor = nil
        $0.tableFooterView = UIView()
        $0.separatorColor = ElementInspector.appearance.quaternaryTextColor
        $0.separatorInset = .insets(
            left: ElementInspector.appearance.horizontalMargins,
            right: ElementInspector.appearance.horizontalMargins
        )
        $0.contentInset = .insets(
            top: -searchView.separatorView.thickness,
            bottom: ElementInspector.appearance.verticalMargins
        )
    }
    
    private let blurStyle: UIBlurEffect.Style = {
        if #available(iOS 13.0, *) {
            return .systemChromeMaterialDark
        }
        
        return .dark
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: blurStyle)
        
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 12
        blurView.layer.borderColor = ElementInspector.appearance.tertiaryTextColor.cgColor
        blurView.layer.borderWidth = 1
        
        return blurView
    }()
    
    private lazy var stackView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            searchView,
            tableView
        ]
    )
    
    @objc func updateTableViewHeight() {
        let height = round(tableViewContentSize.height + tableView.contentInset.verticalInsets)
        
        guard tableViewHeightConstraint.constant != height else {
            return
        }
        
        tableViewHeightConstraint.constant = height
    }
    
    var tableViewContentSize: CGSize = .zero {
        didSet {
            Self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateTableViewHeight), object: nil)
            perform(#selector(updateTableViewHeight), with: nil, afterDelay: 0.01)
            
        }
    }
    
    private lazy var tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: .zero).then {
        $0.priority = .defaultLow
        $0.isActive = true
    }
    
    private lazy var bottomAnchorConstraint = blurView.bottomAnchor.constraint(
        lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor,
        constant: -verticalMargin
    )
    
    override func setup() {
        super.setup()
        
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        #endif
        
        tintColor = ElementInspector.appearance.tintColor
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        preservesSuperviewLayoutMargins = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 6)
        layer.shadowOpacity = 1
        layer.shadowRadius = verticalMargin / 2
        
        blurView.contentView.installView(stackView)
        
        contentView.addSubview(blurView)
        
        [
            blurView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: verticalMargin),
            blurView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: horizontalMargin),
            blurView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -horizontalMargin),
            bottomAnchorConstraint
        ]
        .forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let convertedPoint = convert(point, to: blurView)
        
        if blurView.point(inside: convertedPoint, with: event) {
            return true
        }
        
        DispatchQueue.main.async {
            self.delegate?.hierarchyInspectorViewDidTapOutside(self)
        }
        
        return false
    }
    
    func animate(
        _ animation: Animation,
        duration: TimeInterval = CATransaction.animationDuration(),
        delay: TimeInterval = .zero,
        completion: ((Bool) -> Void)? = nil
    ) {
        transform = animation.startTransform
        
        Self.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: animation.damping,
            initialSpringVelocity: animation.velocity,
            options: animation.options,
            animations: { self.transform = animation.endTransform },
            completion: completion
        )
    }
}

fileprivate extension UIEdgeInsets {
    var verticalInsets: CGFloat {
        top + bottom
    }
}
