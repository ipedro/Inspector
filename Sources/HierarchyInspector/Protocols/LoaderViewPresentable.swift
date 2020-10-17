//
//  LoaderViewPresentable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

protocol LoaderViewPresentable: UIView {
    
    func showActivityIndicator(for operation: Operation)
    
    func removeActivityIndicator(for operation: Operation)
    
}
