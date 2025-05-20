//  Copyright (c) 2022 Pedro Almeida
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

extension DefaultElementAttributesLibrary {
    final class ApplicationAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Application"
        private let application: UIApplication

        init?(with object: NSObject) {
            guard let application = object as? UIApplication else { return nil }
            self.application = application
        }

        private enum Property: String, Swift.CaseIterable {
            case alternateIconName = "Alternate Icon Name"
            case applicationIconBadgeNumber = "Icon Badge Number"
            case applicationState = "State"
            case applicationSupportsShakeToEdit = "Shake To Edit"
            case backgroundRefreshStatus
            case backgroundTimeRemaining
            case isIdleTimerEnabled = "Idle Timer"
            case isProtectedDataAvailable
            case isRegisteredForRemoteNotifications = "Remote Notifications"
            case supportsAlternateIcons = "Alternate Icons"
            case supportsMultipleScenes = "Multiple Scenes"
            case userInterfaceLayoutDirection
        }

        var properties: [InspectorElementProperty] {
            Property.allCases.compactMap { property in
                switch property {
                case .isIdleTimerEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { !self.application.isIdleTimerDisabled },
                        handler: { self.application.isIdleTimerDisabled = !$0 }
                    )
                case .applicationIconBadgeNumber:
                    .integerStepper(
                        title: property.rawValue,
                        value: { self.application.applicationIconBadgeNumber },
                        range: { 0...1000 },
                        stepValue: { 1 },
                        handler: { self.application.applicationIconBadgeNumber = $0 }
                    )
                case .applicationSupportsShakeToEdit:
                    .switch(
                        title: property.rawValue,
                        isOn: { self.application.applicationSupportsShakeToEdit },
                        handler: { self.application.applicationSupportsShakeToEdit = $0 }
                    )
                case .applicationState:
                    .textField(
                        title: property.rawValue,
                        placeholder: .none,
                        axis: .horizontal,
                        value: {
                            switch self.application.applicationState {
                            case .active: return "Active"
                            case .inactive: return "Inactive"
                            case .background: return "Background"
                            @unknown default: return "Unknown"
                            }
                        }
                    )
                case .backgroundTimeRemaining:
                    .none
                case .backgroundRefreshStatus:
                    .none
                case .isProtectedDataAvailable:
                    .none
                case .userInterfaceLayoutDirection:
                    .none
                case .supportsMultipleScenes:
                    .switch(
                        title: property.rawValue,
                        isOn: { self.application.supportsMultipleScenes }
                    )
                case .isRegisteredForRemoteNotifications:
                    .switch(
                        title: property.rawValue,
                        isOn: { self.application.isRegisteredForRemoteNotifications }
                    )
                case .supportsAlternateIcons:
                    .switch(
                        title: property.rawValue,
                        isOn: { self.application.supportsAlternateIcons }
                    )
                case .alternateIconName:
                    .textField(
                        title: property.rawValue,
                        placeholder: .none,
                        value: { self.application.alternateIconName }
                    )
                }
            }
        }
    }
}
