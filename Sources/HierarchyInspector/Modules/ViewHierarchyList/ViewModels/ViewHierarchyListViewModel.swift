//
//  ViewHierarchyListViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewModel: NSObject {
    let rootReference: ViewHierarchyReference
    
    private(set) lazy var childViewModels = rootReference.flattenedInspectableViews.map {
        ViewHierarchyListItemViewModel(reference: $0)
    }
    
    init(reference: ViewHierarchyReference) {
        self.rootReference = reference
    }
    
    let title: String = {
        "More info"
    }()
}

protocol ViewHierarchyListItemViewModelProtocol: AnyObject {
    var title: String { get }
    var subtitle: String { get }
    var isContainer: Bool { get }
    var depth: Int { get }
    var backgroundColor: UIColor? { get }
}

final class ViewHierarchyListItemViewModel: ViewHierarchyListItemViewModelProtocol {
    var backgroundColor: UIColor?
    
    private(set) lazy var title: String = {
        "\(reference.children.isEmpty ? "" : "› ")\(reference.elementName)"
    }()
    
    private(set) lazy var subtitle: String = {
        var strings = [String?]()
        
        var constraints: String? {
            guard let view = reference.view else {
                return nil
            }
            return "\(view.constraints.count) constraints"
        }
        
        var subviews: String? {
            guard isContainer else {
                return nil
            }
            return "\(reference.flattenedViewHierarchy.count) children. (\(reference.children.count) subviews)"
        }
        
        var description: String? {
            guard let view = reference.view else {
                return nil
            }
            return view.description.replacingOccurrences(of: "; ", with: "\n", options: .caseInsensitive)
        }
        
        strings.append(description)
        strings.append(subviews)
        strings.append(constraints)
        
        return strings.compactMap { $0 }.joined(separator: "\n")
    }()
    
    private(set) lazy var isContainer: Bool = reference.children.isEmpty == false
    
    private(set) lazy var depth: Int = reference.depth
    
    // MARK: - Properties
    
    private let reference: ViewHierarchyReference
    
    init(reference: ViewHierarchyReference) {
        self.reference = reference
    }
}