//
//  InspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

extension ElementInspector {
    final class InspectorViewController: UIViewController {
        
        private var viewModel: InspectorViewModel!
        
        private lazy var viewCode = InspectorViewCode().then {
            $0.contentView.addArrangedSubview(viewPanel)
        }
        
        private lazy var viewPanel = PropertyInspectorInputGroup(
            title: "View",
            properties: viewModel.inputs
        )
        
        override func loadView() {
            view = viewCode
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            preferredContentSize = viewCode.scrollView.contentSize
        }
        
        static func create(viewModel: InspectorViewModel) -> InspectorViewController {
            let viewController = InspectorViewController()
            viewController.viewModel = viewModel
            
            return viewController
        }
    }
}
