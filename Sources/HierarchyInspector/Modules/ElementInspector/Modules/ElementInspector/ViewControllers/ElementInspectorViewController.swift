//
//  ElementInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class ElementInspectorViewController: UIViewController {
    private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(host: self)
    
    private var viewModel: ElementInspectorViewModelProtocol!
    
    private var currentPageViewController: UIViewController? {
        didSet {
            if let currentPageViewController = currentPageViewController {
                
                currentPageViewController.willMove(toParent: self)
                
                addChild(currentPageViewController)
                
                viewCode.contentView.installView(currentPageViewController.view)
                
                currentPageViewController.didMove(toParent: self)
            }
            
            if let oldPageViewController = oldValue {
                
                oldPageViewController.willMove(toParent: nil)
                
                oldPageViewController.removeFromParent()
                
                oldPageViewController.view.removeFromSuperview()
            }
        }
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
        
        navigationItem.titleView = viewCode.segmentedControl
        navigationItem.rightBarButtonItem = viewCode.inspectBarButtonItem
        navigationItem.leftBarButtonItem = viewCode.dismissBarButtonItem
        
        viewModel.elementPanels.reversed().forEach {
            viewCode.segmentedControl.insertSegment(with: $0.image.withRenderingMode(.alwaysTemplate), at: 0, animated: false)
        }
        
        guard let firstPanel = viewModel.elementPanels.first else {
            return
        }
        
        viewCode.segmentedControl.selectedSegmentIndex = 0
        
        installPanel(firstPanel)
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
        currentPageViewController = viewModel.viewController(for: panel)
    }
    
    func removeCurrentPanel() {
        currentPageViewController = nil
    }
    
    @objc func toggleInspect() {
        presentHierarchyInspector(animated: true)
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ElementInspectorViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - HierarchyInspectorPresentable

extension ElementInspectorViewController: HierarchyInspectorPresentable {
    var hierarchyInspectorLayers: [ViewHierarchyLayer] {
        [.staticTexts, .controls, .icons]
    }
}

extension ViewHierarchyLayer {
    static let icons: ViewHierarchyLayer = .layer(name: "Icons") { $0 is Icon }
}
