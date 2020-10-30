//
//  OptionSelectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

protocol OptionSelectorViewModelProtocol {
    var numberOfComponents: Int { get }
    
    var title: String? { get }
    
    func numberOfRows(in component: Int) -> Int
    
    func title(for row: Int, in component: Int) -> String?
    
    var selectedRow: (row: Int, component: Int)? { get }
}

final class OptionSelectorViewModel {
    let options: [CustomStringConvertible]
    
    var selectedIndex: Int?
    
    let title: String?
    
    init(title: String?, options: [CustomStringConvertible], selectedIndex: Int?) {
        self.title = title
        self.options = options
        self.selectedIndex = selectedIndex
    }
}

extension OptionSelectorViewModel: OptionSelectorViewModelProtocol {
    var numberOfComponents: Int {
        return 1
    }
    
    func numberOfRows(in component: Int) -> Int {
        switch component {
        case .zero:
            return options.count
            
        default:
            return .zero
        }
    }
    
    func title(for row: Int, in component: Int) -> String? {
        switch component {
        case .zero:
            return options[row].description
            
        default:
            return nil
        }
    }
    
    var selectedRow: (row: Int, component: Int)? {
        guard let selectedIndex = selectedIndex else {
            return nil
        }
        
        return (row: selectedIndex, component: .zero)
    }
    
    
}
