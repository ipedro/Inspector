//
//  ValueHandlers.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.12.20.
//

import UIKit

// MARK: - Value Handlers

public typealias BoolHandler      = ((Bool)     -> Void)
public typealias CGFloatHandler   = ((CGFloat)  -> Void)
public typealias ColorHandler     = ((UIColor?) -> Void)
public typealias DoubleHandler    = ((Double)   -> Void)
public typealias FloatHandler     = ((Float)    -> Void)
public typealias FontHandler      = ((UIFont?)  -> Void)
public typealias ImageHandler     = ((UIImage?) -> Void)
public typealias IntHandler       = ((Int)      -> Void)
public typealias SelectionHandler = ((Int?)     -> Void)
public typealias StringHandler    = ((String?)  -> Void)
