//
//  UITableView+Convenience.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

public extension UITableView {

    // MARK: - Cells
    
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass.self, forCellReuseIdentifier: String(describing: T.self))
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_: T.Type = T.self, for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(identifier)")
        }

        return cell
    }
    
    // MARK: - Headers & Footers
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(_ headerFooterClass: T.Type) {
        register(headerFooterClass.self, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type = T.self) -> T {
        let identifier = String(describing: T.self)
        
        guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T else { fatalError("Could not dequeue header/footer with identifier: \(identifier)")
        }

        return headerFooter
    }
}
