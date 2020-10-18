//
//  ElementInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol ElementInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerForPanel panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController
    
    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController)
}

final class ElementInspectorViewController: UIViewController {
    weak var delegate: ElementInspectorViewControllerDelegate?
    
    private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(host: self)
    
    private var viewModel: ElementInspectorViewModelProtocol!
    
    override var preferredContentSize: CGSize {
        didSet {
            Console.print(self.classForCoder, #function, preferredContentSize)
        }
    }
    
    private var presentedPanelViewController: UIViewController? {
        didSet {
            
            viewCode.emptyLabel.isHidden = presentedPanelViewController != nil
            
            if let panelViewController = presentedPanelViewController {
                
                addChild(panelViewController)
                
                viewCode.contentView.installView(panelViewController.view)
                
                panelViewController.didMove(toParent: self)
            }
            
            if let oldPanelViewController = oldValue {
                
                oldPanelViewController.willMove(toParent: nil)
                
                oldPanelViewController.view.removeFromSuperview()
                
                oldPanelViewController.removeFromParent()
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
        $0.segmentedControl.addTarget(self, action: #selector(didChangeSelectedSegmentIndex), for: .valueChanged)
        
        $0.inspectBarButtonItem.target = self
        $0.inspectBarButtonItem.action = #selector(toggleInspect)
        
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
        
        title = viewModel.reference.elementName
        
        navigationItem.rightBarButtonItem = viewCode.inspectBarButtonItem
        
        if viewModel.showDismissBarButton {
            navigationItem.leftBarButtonItem = viewCode.dismissBarButtonItem
        }
        
        viewModel.elementPanels.reversed().forEach {
            viewCode.segmentedControl.insertSegment(with: $0.image.withRenderingMode(.alwaysTemplate), at: 0, animated: false)
        }
        
        viewCode.segmentedControl.selectedSegmentIndex = viewModel.selectedPanelSegmentIndex
        
        if let selectedPanel = viewModel.selectedPanel {
            installPanel(selectedPanel)
        }
        
        navigationItem.titleView = viewCode.segmentedControl
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
    @objc private func didChangeSelectedSegmentIndex() {
        delegate?.addOperationToQueue(MainThreadOperation(name: UUID().uuidString, closure: { [weak self] in
            guard
                let segmentedControl = self?.viewCode.segmentedControl,
                segmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment,
                let panel = ElementInspectorPanel(rawValue: segmentedControl.selectedSegmentIndex)
            else {
                self?.removeCurrentPanel()
                
                return
            }
            
            // wait for segmented control animation to finish
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self] in
                self?.installPanel(panel)
            }
        }))
    }
    
    @discardableResult
    func selectPanelIfAvailable(_ panel: ElementInspectorPanel) -> Bool {
        guard let index = viewModel.elementPanels.firstIndex(of: panel) else {
            return false
        }
        
        viewCode.segmentedControl.selectedSegmentIndex = index
        
        installPanel(panel)
        
        return true
    }
    
    private func installPanel(_ panel: ElementInspectorPanel) {
        guard let panelViewController = delegate?.elementInspectorViewController(self, viewControllerForPanel: panel, with: viewModel.reference) else {
            presentedPanelViewController = nil
            return
        }
        
        presentedPanelViewController = panelViewController
    }
    
    func removeCurrentPanel() {
        presentedPanelViewController = nil
    }
    
    @objc private func toggleInspect() {
        presentHierarchyInspector(animated: true)
    }
    
    @objc private func close() {
        self.delegate?.elementInspectorViewControllerDidFinish(self)
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
            .tableViewCells,
            .containerViews,
            .allViews
        ]
    }
}

extension ViewHierarchyLayer {
    static let icons: ViewHierarchyLayer = .layer(name: "Icons") { $0 is Icon }
}
