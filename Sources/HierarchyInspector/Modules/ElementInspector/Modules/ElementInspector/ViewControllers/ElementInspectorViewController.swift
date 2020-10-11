//
//  ElementInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol ElementInspectorViewControllerDelegate: AnyObject {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerForPanel panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> UIViewController
}

final class ElementInspectorViewController: UIViewController {
    weak var delegate: ElementInspectorViewControllerDelegate?
    
    private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(host: self)
    
    private var viewModel: ElementInspectorViewModelProtocol!
    
    override var preferredContentSize: CGSize {
        didSet {
            Console.print(self.classForCoder, #function, preferredContentSize)
            
            guard let superview = view.superview else {
                return
            }
            
            view.frame = superview.bounds
            view.layoutIfNeeded()
        }
    }
    
    private var presentedPanelViewController: UIViewController? {
        didSet {
            
            viewCode.emptyLabel.isHidden = presentedPanelViewController != nil
            
            if let panelViewController = presentedPanelViewController {
                
                panelViewController.willMove(toParent: self)
                
                addChild(panelViewController)
                
                viewCode.contentView.installView(panelViewController.view)
                
                panelViewController.didMove(toParent: self)
            }
            
            if let oldPanelViewController = oldValue {
                
                oldPanelViewController.willMove(toParent: nil)
                
                oldPanelViewController.removeFromParent()
                
                oldPanelViewController.view.removeFromSuperview()
            }
        }
    }
    
    private lazy var heightConstraint = viewCode.heightAnchor.constraint(equalToConstant: 0).then {
        $0.isActive = true
    }
    
    private lazy var widthConstraint = viewCode.widthAnchor.constraint(equalToConstant: 0).then {
        $0.isActive = true
    }
    
    private lazy var viewCode = ElementInspectorViewCode().then {
        $0.segmentedControl.addTarget(self, action: #selector(selectedSegment), for: .valueChanged)
        
        $0.inspectBarButtonItem.target = self
        $0.inspectBarButtonItem.action = #selector(toggleInspect)
        
        $0.dismissBarButtonItem.target = self
        $0.dismissBarButtonItem.action = #selector(close)
    }
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.reference.elementName
        
        navigationItem.titleView = viewCode.segmentedControl
        
        navigationItem.rightBarButtonItem = viewCode.inspectBarButtonItem
        
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = viewCode.dismissBarButtonItem
        }
        
        viewModel.elementPanels.reversed().forEach {
            viewCode.segmentedControl.insertSegment(with: $0.image.withRenderingMode(.alwaysTemplate), at: 0, animated: false)
        }
        
        guard let firstPanel = viewModel.elementPanels.first else {
            return
        }
        
        viewCode.segmentedControl.selectedSegmentIndex = 0
        
        installPanel(firstPanel)
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let newSize = calculatePreferredContentSize(with: container)
        
        return newSize
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        let newSize = calculatePreferredContentSize(with: container)
        
        preferredContentSize = newSize
    }
    
    private func calculatePreferredContentSize(with container: UIContentContainer) -> CGSize {
        guard let containerViewController = container as? UIViewController else {
            return .zero
        }
        
        containerViewController.view.layoutIfNeeded()
        
        return containerViewController.preferredContentSize
    }
    
    static func create(viewModel: ElementInspectorViewModelProtocol) -> ElementInspectorViewController {
        let viewController = ElementInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
}

// MARK: - Actions

private extension ElementInspectorViewController {
    @objc func selectedSegment() {
        guard
            viewCode.segmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment,
            let panel = ElementInspectorPanel(rawValue: viewCode.segmentedControl.selectedSegmentIndex)
        else {
            return removeCurrentPanel()
        }
        
        installPanel(panel)
    }
    
    func installPanel(_ panel: ElementInspectorPanel) {
        guard let panelViewController = delegate?.elementInspectorViewController(self, viewControllerForPanel: panel, with: viewModel.reference) else {
            presentedPanelViewController = nil
            return
        }
        
        presentedPanelViewController = panelViewController
    }
    
    func removeCurrentPanel() {
        presentedPanelViewController = nil
    }
    
    @objc func toggleInspect() {
        presentHierarchyInspector(animated: true)
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
}


// MARK: - HierarchyInspectorPresentable

extension ElementInspectorViewController: HierarchyInspectorPresentable {
    var hierarchyInspectorLayers: [ViewHierarchyLayer] {
        [
            .buttons,
            .controls,
            .staticTexts + .icons + .images,
            .stackViews,
            .containerViews,
            .allViews
        ]
    }
}

extension ViewHierarchyLayer {
    static let icons: ViewHierarchyLayer = .layer(name: "Icons") { $0 is Icon }
}
