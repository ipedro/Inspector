//
//  Manager.ActionGroup.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import UIKit

typealias ActionGroups = [ActionGroup]

struct ActionGroup {
    var title: String?
    
    var actions: [Action]
}
