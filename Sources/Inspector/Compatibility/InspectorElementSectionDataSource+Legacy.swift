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

@available(*, deprecated, message: "Compatibility-only protocol; use InspectorElementSectionDataSource directly")
public protocol InspectorElementSectionLegacyDataSource: AnyObject {
    @available(*, deprecated, message: "Use propertyBindings or sectionBinding instead")
    var properties: [InspectorElementProperty] { get }
    var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] { get }
    @available(*, deprecated, message: "Use titleAccessoryBinding instead")
    var titleAccessoryProperty: InspectorElementProperty? { get }
    @available(*, deprecated, message: "Use sectionBindingExtraBindings instead")
    var sectionBindingExtraProperties: [String: () -> [InspectorElementProperty]] { get }
}

public extension InspectorElementSectionDataSource {
    @available(*, deprecated, message: "Use propertyBindings or sectionBinding instead")
    var properties: [InspectorElementProperty] {
        sectionBinding?.makeInspectorElementProperties(
            extraBindings: sectionBindingExtraBindings,
            extraProperties: sectionBindingExtraProperties
        ) ?? []
    }

    @available(*, deprecated, message: "Use titleAccessoryBinding instead")
    var titleAccessoryProperty: InspectorElementProperty? { nil }

    var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] { [:] }

    @available(*, deprecated, message: "Use sectionBindingExtraBindings instead")
    var sectionBindingExtraProperties: [String: () -> [InspectorElementProperty]] { [:] }

    var propertyBindings: [InspectorPropertyBinding] {
        if let sectionBinding {
            let bindingExtras = sectionBindingExtraBindings
                .sorted { $0.key < $1.key }
                .flatMap { _, provider in provider() }

            let propertyExtras = sectionBindingExtraProperties
                .sorted { $0.key < $1.key }
                .map { key, provider -> [InspectorPropertyBinding] in
                    let properties = provider()
                    var bindings: [InspectorPropertyBinding] = []
                    for (index, property) in properties.enumerated() {
                        guard let binding = property.makeBinding(id: "\(key)-\(index)") else {
                            assertionFailure("Unsupported legacy property in sectionBindingExtraProperties for key \(key)")
                            continue
                        }
                        bindings.append(binding)
                    }
                    return bindings
                }
                .flatMap { $0 }
            return sectionBinding.fields + bindingExtras + propertyExtras
        }

        let mapped = properties.enumerated().compactMap { index, property in
            property.makeBinding(id: "legacy-\(index)")
        }
        if mapped.count != properties.count {
            assertionFailure("Unsupported legacy property conversion in \(Self.self)")
        }
        return mapped
    }
}
