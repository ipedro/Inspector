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

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 14.0, *)
public extension View {
    func inspect(
        isPresented: Binding<Bool>,
        inspectorViewHierarchyLayers: [Inspector.ViewHierarchyLayer]? = nil,
        inspectorViewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme? = nil,
        inspectorCommandGroups: [Inspector.CommandsGroup]? = nil,
        inspectorElementLibraries: [InspectorElementLibraryProtocol]? = nil
    ) -> some View {
        modifier(
            InspectorModifier(
                isPresented: isPresented,
                inspectorViewHierarchyLayers: inspectorViewHierarchyLayers,
                inspectorViewHierarchyColorScheme: inspectorViewHierarchyColorScheme,
                inspectorCommandGroups: inspectorCommandGroups,
                inspectorElementLibraries: inspectorElementLibraries
            )
        )
    }
}

@available(iOS 14.0, *)
struct InspectorModifier: ViewModifier {
    @Binding var isPresented: Bool

    var inspectorViewHierarchyLayers: [Inspector.ViewHierarchyLayer]?

    var inspectorViewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme?

    var inspectorCommandGroups: [Inspector.CommandsGroup]?

    var inspectorElementLibraries: [InspectorElementLibraryProtocol]?

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                InspectorUI(
                    inspectorViewHierarchyLayers: inspectorViewHierarchyLayers,
                    inspectorViewHierarchyColorScheme: inspectorViewHierarchyColorScheme,
                    inspectorCommandGroups: inspectorCommandGroups,
                    inspectorElementLibraries: inspectorElementLibraries,
                    didFinish: {
                        isPresented = false
                    }

                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5))
            }

        }
    }
}
#endif
