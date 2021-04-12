//
//  ValueProviders.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.12.20.
//

import UIKit

// MARK: - Value Providers

public typealias BoolProvider               = (() -> Bool)
public typealias CGFloatClosedRangeProvider = (() -> ClosedRange<CGFloat>)
public typealias CGFloatProvider            = (() -> CGFloat)
public typealias ColorProvider              = (() -> UIColor?)
public typealias DoubleClosedRangeProvider  = (() -> ClosedRange<Double>)
public typealias DoubleProvider             = (() -> Double)
public typealias FloatClosedRangeProvider   = (() -> ClosedRange<Float>)
public typealias FloatProvider              = (() -> Float)
public typealias FontProvider               = (() -> UIFont?)
public typealias ImageProvider              = (() -> UIImage?)
public typealias IntClosedRangeProvider     = (() -> ClosedRange<Int>)
public typealias IntProvider                = (() -> Int)
public typealias SelectionProvider          = (() -> Int?)
public typealias StringProvider             = (() -> String?)
