//
//  AlertControllerActionable.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

protocol AlertControllerActionable {
    
    var unselectedAlertAction: String { get }
    
    var selectedAlertAction: String { get }
    
    var emptyText: String { get }
    
}
