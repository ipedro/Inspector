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

protocol ElementPreviewInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func elementPreviewViewController(_ viewController: ElementPreviewInspectorViewController,
                                      showLayerInspectorViewsInside reference: ViewHierarchyReference)

    func elementPreviewViewController(_ viewController: ElementPreviewInspectorViewController,
                                      hideLayerInspectorViewsInside reference: ViewHierarchyReference)
}

final class ElementPreviewInspectorViewController: ElementInspectorPanelViewController {
    private var needsInitialSnapshotRender = true

    weak var delegate: ElementPreviewInspectorViewControllerDelegate?

    private var displayLink: CADisplayLink? {
        didSet {
            if let oldLink = oldValue {
                oldLink.invalidate()
            }

            if let newLink = displayLink {
                newLink.add(to: .current, forMode: .default)
            }
        }
    }

    deinit {
        stopLiveUpdatingSnaphost()
    }

    // MARK: - Properties

    private var viewModel: ElementPreviewInspectorViewModelProtocol!

    private(set) lazy var viewCode = ElementPreviewInspectorViewCode(
        reference: viewModel.reference,
        frame: .zero
    ).then {
        $0.isHighlightingViewsControl.isOn = viewModel.isHighlightingViews
        $0.isLiveUpdatingControl.isOn = viewModel.isLiveUpdating
        $0.isHighlightingViewsControl.addTarget(self, action: #selector(toggleHighlightViews), for: .valueChanged)
        $0.isLiveUpdatingControl.addTarget(self, action: #selector(toggleLiveUpdate), for: .valueChanged)
    }

    // MARK: - Init

    static func create(viewModel: ElementPreviewInspectorViewModelProtocol) -> Self {
        let viewController = Self()
        viewController.viewModel = viewModel

        return viewController
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = viewCode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        renderInitialSnapshotIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        debounce(#selector(startLiveUpdatingSnaphost), after: ElementInspector.configuration.animationDuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopLiveUpdatingSnaphost()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        guard parent == nil else {
            return
        }

        stopLiveUpdatingSnaphost()
    }

    // MARK: - Actions

    func renderInitialSnapshotIfNeeded() {
        guard needsInitialSnapshotRender else {
            return
        }

        needsInitialSnapshotRender = false
        refresh()
    }

    @objc
    func toggleHighlightViews() {
        switch viewModel.isHighlightingViews {
        case true:
            delegate?.elementPreviewViewController(self, hideLayerInspectorViewsInside: viewModel.reference)
        case false:
            delegate?.elementPreviewViewController(self, showLayerInspectorViewsInside: viewModel.reference)
        }
    }

    @objc
    func toggleLiveUpdate() {
        viewModel.isLiveUpdating.toggle()
    }

    // MARK: - Objective-C Actions

    @objc
    func updateHeaderSnapshot() {
        viewCode.updateSnapshot(afterScreenUpdates: false)
    }

    @objc
    func startLiveUpdatingSnaphost() {
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }

    @objc
    func stopLiveUpdatingSnaphost() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(startLiveUpdatingSnaphost),
            object: nil
        )

        displayLink = nil
    }

    @objc
    func refresh() {
        guard viewModel.reference.rootView != nil else {
            return stopLiveUpdatingSnaphost()
        }

        guard viewCode.isPointerInUse == false, viewModel.isLiveUpdating else {
            return
        }

        let operation = MainThreadAsyncOperation(name: "udpate snapshot") { [weak self] in
            self?.viewCode.updateSnapshot(afterScreenUpdates: false)
        }

        delegate?.addOperationToQueue(operation)
    }
}

// MARK: - AttributesInspectorViewCodeDelegate

extension ElementPreviewInspectorViewController: ElementPreviewInspectorViewCodeDelegate {
    func elementPreviewInspectorViewCode(_ view: ElementPreviewInspectorViewCode, isPointerInUse: Bool) {
        view.isLiveUpdatingControl.isEnabled = isPointerInUse == false
        view.isLiveUpdatingControl.setOn(isPointerInUse == false && viewModel.isLiveUpdating, animated: true)
    }
}
