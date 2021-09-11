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

@_implementationOnly import UIKeyboardAnimatable
import UIKit

final class ElementAttributesInspectorViewController: ElementInspectorFormViewController, KeyboardAnimatable {
    // MARK: - Properties

    private var viewModel: AttributesInspectorViewModelProtocol!

    private var needsInitialSnapshotRender = true

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

    private(set) lazy var viewCode = ElementInspectorFormViewCode().then {
        $0.contentView.addArrangedSubview(thumbnailSectionViewCode)

        $0.delegate = self
    }

    private(set) lazy var thumbnailSectionViewCode = AttributesInspectorThumbnailSectionView(
        reference: viewModel.reference,
        frame: .zero
    ).then {
        $0.referenceDetailView.viewModel = viewModel

        $0.isHighlightingViewsControl.isOn = viewModel.isHighlightingViews

        $0.isLiveUpdatingControl.isOn = viewModel.isLiveUpdating

        $0.isHighlightingViewsControl.addTarget(self, action: #selector(toggleHighlightViews), for: .valueChanged)

        $0.isLiveUpdatingControl.addTarget(self, action: #selector(toggleLiveUpdate), for: .valueChanged)

        $0.referenceAccessoryButton.addTarget(self, action: #selector(tapThumbnailAccessory), for: .touchUpInside)
    }

    // MARK: - Init

    static func create(viewModel: AttributesInspectorViewModelProtocol) -> ElementAttributesInspectorViewController {
        let viewController = ElementAttributesInspectorViewController()
        viewController.viewModel = viewModel

        return viewController
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSections()

        animateWhenKeyboard(.willChangeFrame) { info in
            self.viewCode.keyboardHeight = info.keyboardFrame.height
            self.viewCode.layoutIfNeeded()
        }
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

    override func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController, willUpdate property: InspectorElementViewModelProperty) {
        stopLiveUpdatingSnaphost()
    }

    override func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController, didUpdate property: InspectorElementViewModelProperty) {
        let updateOperation = MainThreadOperation(name: "update sections") { [weak self] in
            self?.children.forEach {
                guard let sectionViewController = $0 as? ElementInspectorFormSectionViewController else {
                    return
                }

                sectionViewController.updateValues()
                self?.updateHeaderDetails()
            }
        }

        updateOperation.completionBlock = {
            DispatchQueue.main.async { [weak self] in
                self?.startLiveUpdatingSnaphost()
            }
        }

        formDelegate?.addOperationToQueue(updateOperation)
    }

    override func elementInspectorFormSectionViewController(_ viewController: ElementInspectorFormSectionViewController, didToggle isCollapsed: Bool) {
        stopLiveUpdatingSnaphost()

        animatePanel(
            animations: { [weak self] in
                guard let self = self else { return }

                viewController.isCollapsed.toggle()

                let sectionViewControllers = self.children.compactMap { $0 as? ElementInspectorFormSectionViewController }

                for sectionViewController in sectionViewControllers where sectionViewController !== viewController {
                    sectionViewController.isCollapsed = true
                }
            },
            completion: { [weak self] _ in
                self?.startLiveUpdatingSnaphost()
            }
        )
    }

    deinit {
        stopLiveUpdatingSnaphost()
    }

    override func animatePanel(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        stopLiveUpdatingSnaphost()

        super.animatePanel(animations: animations) { finished in
            completion?(finished)

            DispatchQueue.main.async { [weak self] in
                self?.startLiveUpdatingSnaphost()
            }
        }
    }
}

// MARK: - Objective-C Actions

@objc extension ElementAttributesInspectorViewController {
    func updateHeaderDetails() {
        thumbnailSectionViewCode.referenceDetailView.viewModel = viewModel
    }

    func updateHeaderSnapshot() {
        thumbnailSectionViewCode.updateSnapshot(afterScreenUpdates: false)
    }

    func startLiveUpdatingSnaphost() {
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
    }

    func stopLiveUpdatingSnaphost() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(startLiveUpdatingSnaphost),
            object: nil
        )

        displayLink = nil
    }

    func refresh() {
        guard viewModel.reference.rootView != nil else {
            return stopLiveUpdatingSnaphost()
        }

        guard viewCode.isPointerInUse == false, viewModel.isLiveUpdating else {
            return
        }

        let operation = MainThreadAsyncOperation(name: "udpate snapshot") { [weak self] in
            self?.thumbnailSectionViewCode.updateSnapshot(afterScreenUpdates: false)
        }

        formDelegate?.addOperationToQueue(operation)
    }
}

// MARK: - Actions

private extension ElementAttributesInspectorViewController {
    func renderInitialSnapshotIfNeeded() {
        guard needsInitialSnapshotRender else {
            return
        }

        needsInitialSnapshotRender = false
        refresh()
    }

    func loadSections() {
        updateHeaderDetails()
        updateHeaderSnapshot()

        viewModel.sectionViewModels.enumerated().forEach { index, sectionViewModel in

            let sectionViewController = ElementInspectorFormSectionViewController.create(viewModel: sectionViewModel).then {
                $0.isCollapsed = index > 0
                $0.delegate = self
            }

            addChild(sectionViewController)

            viewCode.contentView.addArrangedSubview(sectionViewController.view)

            sectionViewController.didMove(toParent: self)
        }
    }

    @objc
    func toggleHighlightViews() {
        let operation = MainThreadAsyncOperation(name: "toggle layers") { [weak self] in
            guard
                let self = self,
                let formDelegate = self.formDelegate
            else {
                return
            }

            guard self.viewModel.isHighlightingViews else {
                formDelegate.elementInspectorViewController(self, showLayerInspectorViewsInside: self.viewModel.reference)
                return
            }

            formDelegate.elementInspectorViewController(self, hideLayerInspectorViewsInside: self.viewModel.reference)
        }

        formDelegate?.addOperationToQueue(operation)
    }

    @objc
    func toggleLiveUpdate() {
        viewModel.isLiveUpdating.toggle()
    }

    @objc
    func tapThumbnailAccessory() {
        animatePanel { [weak self] in
            self?.thumbnailSectionViewCode.isCollapsed.toggle()
        }
    }
}

// MARK: - AttributesInspectorViewCodeDelegate

extension ElementAttributesInspectorViewController: ElementInspectorFormViewCodeDelegate {
    func elementInspectorFormViewCode(_ viewCode: ElementInspectorFormViewCode, isPointerInUse: Bool) {
        thumbnailSectionViewCode.isLiveUpdatingControl.isEnabled = isPointerInUse == false
        thumbnailSectionViewCode.isLiveUpdatingControl.setOn(isPointerInUse == false && viewModel.isLiveUpdating, animated: true)
    }
}
