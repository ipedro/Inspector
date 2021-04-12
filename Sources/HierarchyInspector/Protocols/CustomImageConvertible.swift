//
//  CustomImageConvertible.swift
//  
//
//  Created by Pedro on 12.04.21.
//

import UIKit

protocol CustomImageConvertible {
    var image: UIImage? { get }
}

extension Array where Element: CustomImageConvertible {
    var withImages: Self {
        filter { $0.image != nil }
    }
}
