//
//  ViewHierarchyListViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewModel: NSObject {
    let rootReference: ViewHierarchyReference
    
    private(set) lazy var childViewModels: [ViewHierarchyListItemViewModel] = {
        var array = [ViewHierarchyListItemViewModel(reference: rootReference)]
        
        rootReference.flattenedViewHierarchy.forEach {
            array.append(ViewHierarchyListItemViewModel(reference: $0))
        }
        
        return array
    }()
    
    init(reference: ViewHierarchyReference) {
        self.rootReference = reference
    }
    
    let title: String = {
        "More info"
    }()
}
