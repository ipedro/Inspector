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
@_implementationOnly import UIKeyCommandTableView

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
                
                let globalFrame = convert(frame, to: nil)
                
                return globalFrame.height + globalFrame.origin.y - safeAreaInsets.bottom - keyboardFrame.origin.y
            }()
            
            bottomAnchorConstraint.constant = (visibleHeight + verticalMargin) * -1
        }
    }
    
    weak var delegate: HierarchyInspectorViewDelegate?
    
    private(set) lazy var searchView = HierarchyInspectorSearchView()
    
    private(set) lazy var tableView = UIKeyCommandTableView(
        .keyboardDismissMode(.onDrag),
        .indicatorStyle(.white),
        .backgroundColor(nil),
        .tableFooterView(UIView()),
        .separatorColor(ElementInspector.appearance.quaternaryTextColor),
        .automaticRowHeight,
        .estimatedRowHeight(100),
        .separatorInset(
            left: ElementInspector.appearance.horizontalMargins,
            right: ElementInspector.appearance.horizontalMargins
        ),
        .contentInset(
            top: -searchView.separatorView.thickness,
            bottom: ElementInspector.appearance.verticalMargins
        )
    )
    
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
        blurView.layer.cornerRadius = ElementInspector.appearance.verticalMargins
        blurView.layer.borderColor = ElementInspector.appearance.tertiaryTextColor.cgColor
        blurView.layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            blurView.layer.cornerCurve = .continuous
        }
        
        return blurView
    }()
    
    private lazy var stackView = UIStackView.vertical(
        .arrangedSubviews(
            searchView,
            tableView
        )
    )
    
    @objc func updateTableViewHeight() {
        let height = round(tableViewContentSize.height + tableView.contentInset.verticalInsets)
        
        guard tableViewHeightConstraint.constant != height else {
            return
        }
        
        tableViewHeightConstraint.constant = height
        layoutIfNeeded()
    }
    
    var tableViewContentSize: CGSize = .zero {
        didSet {
            debounce(#selector(updateTableViewHeight), after: 0.01)
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
        duration: TimeInterval = ElementInspector.configuration.animationDuration,
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
