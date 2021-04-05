//
//  CaseIterable+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.12.20.
//

import MapKit

extension MKMapType: CaseIterable {
    typealias AllCases = [MKMapType]
    
    public static let allCases: [MKMapType] = [
        .standard,
        .satellite,
        .hybrid,
        .satelliteFlyover,
        .hybridFlyover,
        .mutedStandard
    ]
}
