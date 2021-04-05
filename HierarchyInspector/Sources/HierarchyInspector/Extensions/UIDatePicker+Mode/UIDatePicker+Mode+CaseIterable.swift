//
//  UIDatePicker.Mode+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

extension UIDatePicker.Mode: CaseIterable {
    typealias AllCases = [UIDatePicker.Mode]
    
    public static let allCases: [UIDatePicker.Mode] = [
        .time,
        .date,
        .dateAndTime,
        .countDownTimer
    ]
}
