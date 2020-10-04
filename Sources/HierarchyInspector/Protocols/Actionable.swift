//
//  Actionable.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

protocol Actionable {
    
    var unselectedActionTitle: String { get }
    
    var selectedActionTitle: String { get }
    
    var emptyActionTitle: String { get }
    
}
