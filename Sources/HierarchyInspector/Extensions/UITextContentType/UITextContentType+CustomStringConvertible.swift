//
//  UITextContentType+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextContentType: CustomStringConvertible {
    var description: String {
        #if swift(>=4.2)
        if #available(iOS 12.0, *) {
            switch self {
            case .name:
                return "Name"
            case .namePrefix:
                return "Name Prefix"
            case .givenName:
                return "Given Name"
            case .middleName:
                return "Middle Name"
            case .familyName:
                return "Family Name"
            case .nameSuffix:
                return "Name Suffix"
            case .nickname:
                return "Nickname"
            case .jobTitle:
                return "Job Title"
            case .organizationName:
                return "Organization Name"
            case .location:
                return "Location"
            case .fullStreetAddress:
                return "Full Street Address"
            case .streetAddressLine1:
                return "Street Address Line 1"
            case .streetAddressLine2:
                return "Street Address Line 2"
            case .addressCity:
                return "Address City"
            case .addressState:
                return "Address State"
            case .addressCityAndState:
                return "Address City And State"
            case .sublocality:
                return "Sublocality"
            case .countryName:
                return "Country Name"
            case .postalCode:
                return "Postal Code"
            case .telephoneNumber:
                return "Telephone Number"
            case .emailAddress:
                return "Email Address"
            case .URL:
                return "URL"
            case .creditCardNumber:
                return "Credit Card Number"
            case .username:
                return "Username"
            case .password:
                return "Password"
            case .newPassword:
                return "New Password"
            case .oneTimeCode:
                return "One Time Code"
            default:
                return "\(self) (unsupported)"
            }
        }
        #else
        switch self {
        case .name:
            return "Name"
        case .namePrefix:
            return "Name Prefix"
        case .givenName:
            return "Given Name"
        case .middleName:
            return "Middle Name"
        case .familyName:
            return "Family Name"
        case .nameSuffix:
            return "Name Suffix"
        case .nickname:
            return "Nickname"
        case .jobTitle:
            return "Job Title"
        case .organizationName:
            return "Organization Name"
        case .location:
            return "Location"
        case .fullStreetAddress:
            return "Full Street Address"
        case .streetAddressLine1:
            return "Street Address Line 1"
        case .streetAddressLine2:
            return "Street Address Line 2"
        case .addressCity:
            return "Address City"
        case .addressState:
            return "Address State"
        case .addressCityAndState:
            return "Address City And State"
        case .sublocality:
            return "Sublocality"
        case .countryName:
            return "Country Name"
        case .postalCode:
            return "Postal Code"
        case .telephoneNumber:
            return "Telephone Number"
        case .emailAddress:
            return "Email Address"
        case .URL:
            return "URL"
        case .creditCardNumber:
            return "Credit Card Number"
        case .username:
            return "Username"
        case .password:
            return "Password"
        default:
            return "\(self) (unsupported)"
        }
        #endif
        
        return String(describing: self)
    }
}
