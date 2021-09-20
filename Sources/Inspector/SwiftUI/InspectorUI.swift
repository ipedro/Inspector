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
final class InspectorUI: UIViewControllerRepresentable, InspectorSwiftUIHostable {
    // MARK: - InspectorSwiftUIHostable

    let inspectorViewHierarchyLayers: [Inspector.ViewHierarchyLayer]?

    let inspectorViewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme?

    let inspectorCommandGroups: [Inspector.CommandsGroup]?

    let inspectorElementLibraries: [InspectorElementLibraryProtocol]?

    var didFinish: (() -> Void)?

    var window: UIWindow? {
        UIApplication.shared.windows.first { $0.isKeyWindow }
    }

    // MARK: - Initializer

    init(
        inspectorViewHierarchyLayers: [Inspector.ViewHierarchyLayer]?,
        inspectorViewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme?,
        inspectorCommandGroups: [Inspector.CommandsGroup]?,
        inspectorElementLibraries: [InspectorElementLibraryProtocol]?,
        didFinish: (() -> Void)?
    ) {
        self.inspectorViewHierarchyLayers = inspectorViewHierarchyLayers
        self.inspectorViewHierarchyColorScheme = inspectorViewHierarchyColorScheme
        self.inspectorCommandGroups = inspectorCommandGroups
        self.inspectorElementLibraries = inspectorElementLibraries
        self.didFinish = didFinish
    }

    func hierarchyInspectorDidFinish(_ coordinator: HierarchyInspectorCoordinator) {
        didFinish?()
    }

    func alertController(
        title: String?,
        message: String? = nil,
        preferredStyle: UIAlertController.Style = .alert
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )

        alertController.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: { _ in
                    self.didFinish?()
                }
            )
        )

        return alertController
    }

    func makeUIViewController(context: Context) -> UIViewController {
        Inspector.manager.swiftUIhost = self

        guard let coordinator = Inspector.manager.makeHierarchyInspectorCoordinator() else {
            return alertController(title: "Couldn't present inspector")
        }

        return coordinator.start()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif
