//
//  AttributesInspectorSectionProperty+Typealiases.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.12.20.
//

import UIKit

// MARK: - Providers

extension AttributesInspectorSectionProperty {
    
    typealias BoolProvider               = (() -> Bool)
    typealias CGFloatClosedRangeProvider = (() -> ClosedRange<CGFloat>)
    typealias CGFloatProvider            = (() -> CGFloat)
    typealias ColorProvider              = (() -> UIColor?)
    typealias DoubleClosedRangeProvider  = (() -> ClosedRange<Double>)
    typealias DoubleProvider             = (() -> Double)
    typealias FloatClosedRangeProvider   = (() -> ClosedRange<Float>)
    typealias FloatProvider              = (() -> Float)
    typealias FontProvider               = (() -> UIFont?)
    typealias ImageProvider              = (() -> UIImage?)
    typealias IntClosedRangeProvider     = (() -> ClosedRange<Int>)
    typealias IntProvider                = (() -> Int)
    typealias SelectionProvider          = (() -> Int?)
    typealias StringProvider             = (() -> String?)
    
}

// MARK: - Value handlers

extension AttributesInspectorSectionProperty {
    
    typealias BoolHandler      = ((Bool)     -> Void)
    typealias CGFloatHandler   = ((CGFloat)  -> Void)
    typealias ColorHandler     = ((UIColor?) -> Void)
    typealias DoubleHandler    = ((Double)   -> Void)
    typealias FloatHandler     = ((Float)    -> Void)
    typealias FontHandler      = ((UIFont?)  -> Void)
    typealias ImageHandler     = ((UIImage?) -> Void)
    typealias IntHandler       = ((Int)      -> Void)
    typealias SelectionHandler = ((Int?)     -> Void)
    typealias StringHandler    = ((String?)  -> Void)
    
}
