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
final class InspectorUI: UIViewControllerRepresentable, InspectorSwiftUIHost, InspectorCustomizationProviding {
    // MARK: - InspectorSwiftUIHostable

    let viewHierarchyLayers: [Inspector.ViewHierarchyLayer]?

    let elementColorProvider: Inspector.ElementColorProvider?

    let commandGroups: [Inspector.CommandsGroup]?

    let elementLibraries: [Inspector.ElementPanelType: [InspectorElementLibraryProtocol]]?

    let elementIconProvider: Inspector.ElementIconProvider?

    var didFinish: (() -> Void)?

    // MARK: - Initializer

    init(
        layers: [Inspector.ViewHierarchyLayer]?,
        colorScheme: Inspector.ElementColorProvider?,
        commandGroups: [Inspector.CommandsGroup]?,
        elementLibraries: [Inspector.ElementPanelType: [InspectorElementLibraryProtocol]]?,
        elementIconProvider: Inspector.ElementIconProvider?,
        didFinish: (() -> Void)?
    ) {
        viewHierarchyLayers = layers
        elementColorProvider = colorScheme
        self.commandGroups = commandGroups
        self.elementLibraries = elementLibraries
        self.elementIconProvider = elementIconProvider
        self.didFinish = didFinish
    }

    func insectorViewWillFinishPresentation() {
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
        Inspector.sharedInstance.customization = self
        Inspector.sharedInstance.swiftUIHost = self
        Inspector.start()

        guard
            let presenter = ViewHierarchy.shared.topPresentableViewController,
            let coordinator = Inspector.sharedInstance.manager?.makeInspectorViewCoordinator(presentedBy: presenter)
        else {
            return alertController(title: "Couldn't present inspector")
        }

        return coordinator.start()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif
