//
//  UITextContentType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextContentType: CaseIterable {
    public typealias AllCases = [UITextContentType]
    
    public static var allCases: [UITextContentType] {
        
        #if swift(>=4.2)
        if #available(iOS 12.0, *) {
            return [
                .name,
                .namePrefix,
                .givenName,
                .middleName,
                .familyName,
                .nameSuffix,
                .nickname,
                // --
                .jobTitle,
                .organizationName,
                // --
                .location,
                .fullStreetAddress,
                .streetAddressLine1,
                .streetAddressLine2,
                .addressCity,
                .addressState,
                .addressCityAndState,
                .sublocality,
                .countryName,
                .postalCode,
                // --
                .telephoneNumber,
                .emailAddress,
                // --
                .URL,
                .creditCardNumber,
                // --
                .username,
                .password,
                .newPassword,
                .oneTimeCode,
            ]
        }
        #else
        return [
            .name,
            .namePrefix,
            .givenName,
            .middleName,
            .familyName,
            .nameSuffix,
            .nickname,
            // --
            .jobTitle,
            .organizationName,
            // --
            .location,
            .fullStreetAddress,
            .streetAddressLine1,
            .streetAddressLine2,
            .addressCity,
            .addressState,
            .addressCityAndState,
            .sublocality,
            .countryName,
            .postalCode,
            // --
            .telephoneNumber,
            .emailAddress,
            // --
            .URL,
            .creditCardNumber,
            // --
            .username,
            .password
        ]
        #endif
        return []
    }
}
