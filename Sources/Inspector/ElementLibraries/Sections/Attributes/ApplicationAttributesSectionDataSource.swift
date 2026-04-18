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

import InspectorContract
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

        var propertyBindings: [InspectorPropertyBinding] {
            Property.allCases.compactMap { property in
                switch property {
                case .isIdleTimerEnabled:
                    .init(
                        descriptor: .init(
                            id: "is-idle-timer-enabled",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(!self.application.isIdleTimerDisabled) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            self.application.isIdleTimerDisabled = !isEnabled
                        }
                    )
                case .applicationIconBadgeNumber:
                    .init(
                        descriptor: .init(
                            id: "application-icon-badge-number",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(min: 0, max: 1000, step: 1, isDecimal: false)),
                            editability: .editable
                        ),
                        read: { .number(Double(self.application.applicationIconBadgeNumber)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            self.application.applicationIconBadgeNumber = Int(value)
                        }
                    )
                case .applicationSupportsShakeToEdit:
                    .init(
                        descriptor: .init(
                            id: "application-supports-shake-to-edit",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(self.application.applicationSupportsShakeToEdit) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            self.application.applicationSupportsShakeToEdit = isEnabled
                        }
                    )
                case .applicationState:
                    .init(
                        descriptor: .init(
                            id: "application-state",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, allowsNil: true)),
                            editability: .readOnly,
                            presentation: .init(axis: .horizontal)
                        ),
                        read: { .string(self.applicationStateDescription()) },
                        write: nil
                    )
                case .backgroundTimeRemaining:
                    nil
                case .backgroundRefreshStatus:
                    nil
                case .isProtectedDataAvailable:
                    nil
                case .userInterfaceLayoutDirection:
                    nil
                case .supportsMultipleScenes:
                    .init(
                        descriptor: .init(
                            id: "supports-multiple-scenes",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .readOnly
                        ),
                        read: { .bool(self.application.supportsMultipleScenes) },
                        write: nil
                    )
                case .isRegisteredForRemoteNotifications:
                    .init(
                        descriptor: .init(
                            id: "is-registered-for-remote-notifications",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .readOnly
                        ),
                        read: { .bool(self.application.isRegisteredForRemoteNotifications) },
                        write: nil
                    )
                case .supportsAlternateIcons:
                    .init(
                        descriptor: .init(
                            id: "supports-alternate-icons",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .readOnly
                        ),
                        read: { .bool(self.application.supportsAlternateIcons) },
                        write: nil
                    )
                case .alternateIconName:
                    .init(
                        descriptor: .init(
                            id: "alternate-icon-name",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, allowsNil: true)),
                            editability: .readOnly
                        ),
                        read: { .string(self.application.alternateIconName) },
                        write: nil
                    )
                }
            }
        }

        private func applicationStateDescription() -> String {
            switch application.applicationState {
            case .active:
                return "Active"
            case .inactive:
                return "Inactive"
            case .background:
                return "Background"
            @unknown default:
                return "Unknown"
            }
        }
    }
}
