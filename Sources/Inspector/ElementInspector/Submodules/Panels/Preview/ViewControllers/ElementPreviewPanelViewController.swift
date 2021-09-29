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

protocol ElementPreviewPanelViewControllerDelegate: ViewHierarchyActionableProtocol & OperationQueueManagerProtocol {
    func elementPreviewPanelViewController(_ viewController: ElementPreviewPanelViewController,
                                           didTap colorPreviewControl: ColorPreviewControl)
}

final class ElementPreviewPanelViewController: ElementInspectorPanelViewController {
    private var needsInitialSnapshotRender = true

    weak var delegate: ElementPreviewPanelViewControllerDelegate?

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

    func selectBackgroundStyle(_ backgroundStyle: ThumbnailBackgroundStyle) {
        viewCode.backgroundColorControl.selectedColor = backgroundStyle.color
        viewCode.thumbnailView.backgroundStyle = backgroundStyle
    }

    deinit {
        stopLiveUpdatingSnaphost()
    }

    // MARK: - Properties

    private var viewModel: ElementPreviewPanelViewModelProtocol!

    private(set) lazy var viewCode = ElementPreviewPanelViewCode(
        element: viewModel.element,
        frame: .zero
    ).then {
        $0.delegate = self
        $0.isHighlightingViewsControl.isOn = viewModel.isHighlightingViews

        $0.isLiveUpdatingControl.isOn = viewModel.isLiveUpdating

        $0.isHighlightingViewsControl.addTarget(self, action: #selector(toggleHighlightViews), for: .valueChanged)

        $0.isLiveUpdatingControl.addTarget(self, action: #selector(toggleLiveUpdate), for: .valueChanged)
    }

    // MARK: - Init

    convenience init(viewModel: ElementPreviewPanelViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
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

        startLiveUpdatingSnaphost()
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
        guard needsInitialSnapshotRender else { return }

        needsInitialSnapshotRender = false

        refresh()
    }

    @objc
    func toggleHighlightViews() {
        let layerAction: ViewHierarchyLayerAction = viewModel.isHighlightingViews ? .hideHighlight : .showHighlight

        delegate?.perform(action: .layer(layerAction), with: viewModel.element, from: .none)
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
        debounce(#selector(makeDisplayLink), after: .average)
    }

    @objc
    func makeDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }

    @objc
    func stopLiveUpdatingSnaphost() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(makeDisplayLink),
            object: nil
        )

        displayLink = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        stopLiveUpdatingSnaphost()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        startLiveUpdatingSnaphost()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        startLiveUpdatingSnaphost()
    }

    @objc
    func refresh() {
        guard viewModel.element.rootView != nil else {
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

extension ElementPreviewPanelViewController: ElementPreviewPanelViewCodeDelegate {
    func elementPreviewPanelViewCode(_ view: ElementPreviewPanelViewCode, didTap colorPreviewControl: ColorPreviewControl) {
        delegate?.elementPreviewPanelViewController(self, didTap: colorPreviewControl)
    }
    
    func elementPreviewPanelViewCode(_ view: ElementPreviewPanelViewCode, isPointerInUse: Bool) {
        view.isLiveUpdatingControl.isEnabled = isPointerInUse == false

        view.isLiveUpdatingControl.setOn(isPointerInUse == false && viewModel.isLiveUpdating, animated: true)
    }
}
