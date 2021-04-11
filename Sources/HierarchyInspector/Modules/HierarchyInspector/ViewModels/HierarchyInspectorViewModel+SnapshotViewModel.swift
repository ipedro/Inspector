//
//  HierarchyInspectorViewModel+SnapshotViewModel.swift
//  
//
//  Created by Pedro on 10.04.21.
//

import UIKit

extension HierarchyInspectorViewModel {
    final class SnapshotViewModel: HierarchyInspectorViewModelSectionProtocol {
        
        struct Details: HierarchyInspectorSnapshotCellViewModelProtocol {
            let title: String
            var isEnabled: Bool
            let subtitle: String
            let image: UIImage?
            let depth: Int
            let reference: ViewHierarchyReference
        }
        
        var searchQuery: String? {
            didSet {
                loadData()
            }
        }
        
        let snapshot: ViewHierarchySnapshot
        
        private var searchResults = [Details]()
        
        init(snapshot: ViewHierarchySnapshot) {
            self.snapshot = snapshot
        }
        
        var isEmpty: Bool { searchResults.isEmpty }
        
        let numberOfSections = 1
        
        func selectRow(at indexPath: IndexPath) ->ViewHierarchyReference? {
            searchResults[indexPath.row].reference
        }
        
        func isRowEnabled(at indexPath: IndexPath) -> Bool {
            searchResults[indexPath.row].isEnabled
        }
        
        func numberOfRows(in section: Int) -> Int {
            searchResults.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            "\(searchResults.count) Search results in \(snapshot.viewHierarchy.elementName)"
        }
        
        func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
            .snaphot(searchResults[indexPath.row])
        }
        
        func loadData() {
            guard let searchQuery = searchQuery else {
                searchResults = []
                return
            }
            
            let flattenedViewHierarchy = [snapshot.viewHierarchy] + snapshot.flattenedViewHierarchy
            
            searchResults = flattenedViewHierarchy.filter {
                $0.elementName.localizedCaseInsensitiveContains(searchQuery)
            }.map({ element -> Details in
                
                let title: String = {
                    if
                        let textElement = element.view as? TextElement,
                        let text = textElement.content
                    {
                        return "\"\(text)\""
                    }
                    
                    return element.elementName
                }()
                
                return Details(
                    title: title,
                    isEnabled: true,
                    subtitle: element.elementDescription,
                    image: element.iconImage(),
                    depth: element.depth,
                    reference: element
                )
            })
        }
        
    }
}
