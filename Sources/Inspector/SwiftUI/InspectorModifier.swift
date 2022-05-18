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
        layers: [Inspector.ViewHierarchyLayer]? = nil,
        colorScheme: Inspector.ElementColorProvider? = nil,
        commandGroups: [Inspector.CommandsGroup]? = nil,
        elementLibraries: [Inspector.ElementPanelType: [InspectorElementLibraryProtocol]]? = nil,
        elementIconProvider: Inspector.ElementIconProvider? = nil
    ) -> some View {
        modifier(
            InspectorModifier(
                isPresented: isPresented,
                viewHierarchyLayers: layers,
                elementColorProvider: colorScheme,
                commandGroups: commandGroups,
                elementLibraries: elementLibraries,
                inspectorIconProvider: elementIconProvider
            )
        )
    }
}

@available(iOS 14.0, *)
struct InspectorModifier: ViewModifier {
    @Binding var isPresented: Bool

    var viewHierarchyLayers: [Inspector.ViewHierarchyLayer]?

    var elementColorProvider: Inspector.ElementColorProvider?

    var commandGroups: [Inspector.CommandsGroup]?

    var elementLibraries: [Inspector.ElementPanelType: [InspectorElementLibraryProtocol]]?

    var inspectorIconProvider: Inspector.ElementIconProvider?

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                InspectorUI(
                    layers: viewHierarchyLayers,
                    colorScheme: elementColorProvider,
                    commandGroups: commandGroups,
                    elementLibraries: elementLibraries,
                    elementIconProvider: inspectorIconProvider,
                    didFinish: {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .center)))
            }
        }
    }
}
#endif
