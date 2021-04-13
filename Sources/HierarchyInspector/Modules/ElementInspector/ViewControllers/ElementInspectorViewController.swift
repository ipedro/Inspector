//
//  ElementInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol ElementInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerFor panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController
    
    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController)
}

final class ElementInspectorViewController: HierarchyInspectableViewController {
    
    // MARK: - HierarchyInspectorPresentable
    
    override var hierarchyInspectorLayers: [ViewHierarchyLayer] {
        [
            .buttons,
            .controls,
            .staticTexts + .icons + .images,
            .stackViews,
            .tableViewCells,
            .containerViews,
            .layer(name: "Base View", filter: { view -> Bool in
                view is BaseView
            })
        ]
    }
    
    weak var delegate: ElementInspectorViewControllerDelegate?
    
    private var viewModel: ElementInspectorViewModelProtocol! {
        didSet {
            title = viewModel.reference.elementName
        }
    }
    
    override var preferredContentSize: CGSize {
        didSet {
            Console.print(self.classForCoder, #function, preferredContentSize)
        }
    }
    
    private var presentedPanelViewController: UIViewController? {
        didSet {
            hierarchyInspectorManager.removeAllLayers()
            
            viewCode.emptyLabel.isHidden = presentedPanelViewController != nil
            
            if let panelViewController = presentedPanelViewController {
                
                addChild(panelViewController)
                
                view.setNeedsLayout()
                
                viewCode.contentView.installView(panelViewController.view, priority: .required)
                
                panelViewController.didMove(toParent: self)
                
                view.layoutIfNeeded()
            }
            
            if let oldPanelViewController = oldValue {
                
                oldPanelViewController.willMove(toParent: nil)
                
                oldPanelViewController.view.removeFromSuperview()
                
                oldPanelViewController.removeFromParent()
            }
        }
    }
    
    private lazy var viewCode = ElementInspectorViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.appearance.panelPreferredCompressedSize
        )
    ).then {
        $0.segmentedControl.addTarget(self, action: #selector(didChangeSelectedSegmentIndex), for: .valueChanged)
        
        $0.dismissBarButtonItem.target = self
        $0.dismissBarButtonItem.action = #selector(close)
    }
    
    // MARK: - Init
    
    static func create(viewModel: ElementInspectorViewModelProtocol) -> ElementInspectorViewController {
        let viewController = ElementInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = viewCode.segmentedControl
        
        navigationItem.rightBarButtonItem = inspectBarButtonItem
        
        if viewModel.showDismissBarButton {
            navigationItem.leftBarButtonItem = viewCode.dismissBarButtonItem
        }
        
        viewModel.elementPanels.reversed().forEach {
            viewCode.segmentedControl.insertSegment(
                with: $0.image.withRenderingMode(.alwaysTemplate),
                at: .zero,
                animated: false
            )
        }
        
        viewCode.segmentedControl.selectedSegmentIndex = viewModel.selectedPanelSegmentIndex
        
        if let selectedPanel = viewModel.selectedPanel {
            installPanel(selectedPanel)
        }
    }
    
    // MARK: - Content Size
    
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
        
        return containerViewController.preferredContentSize
    }
}

// MARK: - Actions

extension ElementInspectorViewController {
    
    @discardableResult
    func selectPanelIfAvailable(_ panel: ElementInspectorPanel) -> Bool {
        guard let index = viewModel.elementPanels.firstIndex(of: panel) else {
            return false
        }
        
        viewCode.segmentedControl.selectedSegmentIndex = index
        
        installPanel(panel)
        
        return true
    }
    
    func removeCurrentPanel() {
        presentedPanelViewController = nil
    }
    
}

// MARK: - Private Actions

private extension ElementInspectorViewController {
    
    func installPanel(_ panel: ElementInspectorPanel) {
        guard let panelViewController = delegate?.elementInspectorViewController(self, viewControllerFor: panel, with: viewModel.reference) else {
            presentedPanelViewController = nil
            return
        }
        
        presentedPanelViewController = panelViewController
    }
    
    @objc
    func didChangeSelectedSegmentIndex() {
        delegate?.cancelAllOperations()
        
        guard
            viewCode.segmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment,
            let panel = ElementInspectorPanel(rawValue: viewCode.segmentedControl.selectedSegmentIndex)
        else {
            removeCurrentPanel()
            return
        }
        
        installPanel(panel)
    }
    
    @objc
    func close() {
        self.delegate?.elementInspectorViewControllerDidFinish(self)
    }
    
}
