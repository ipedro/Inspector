//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
