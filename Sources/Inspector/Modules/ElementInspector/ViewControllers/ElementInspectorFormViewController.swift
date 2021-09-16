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

protocol ElementInspectorFormViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        didTap colorPicker: ColorPreviewControl)

    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        didTap imagePicker: ImagePreviewControl)

    func elementInspectorViewController(_ viewController: ElementInspectorFormViewController,
                                        didTap optionSelector: OptionListControl)
}

public struct ElementInspectorFormSection {
    public var title: String?
    public var viewModels: [InspectorElementViewModelProtocol]

    public init(
        title: String? = nil,
        rows: [InspectorElementViewModelProtocol]
    ) {
        self.title = title
        self.viewModels = rows
    }
}

public extension Array where Element == ElementInspectorFormSection {
    static func single(_ viewModel: InspectorElementViewModelProtocol) -> Self {
        [.init(rows: [viewModel])]
    }
}

protocol ElementInspectorFormViewControllerDataSource: AnyObject {
    func typeForRow(at indexPath: IndexPath) -> InspectorElementFormSectionView.Type?
    var sections: [ElementInspectorFormSection] { get }
}

protocol ElementInspectorBaseViewControllerProtocol {
    var viewCode: ElementInspectorFormView { get }
}

typealias ElementInspectorFormViewController = ElementInspectorBaseFormViewController & ElementInspectorBaseViewControllerProtocol

class ElementInspectorBaseFormViewController: ElementInspectorPanelViewController, ElementInspectorFormSectionViewControllerDelegate, KeyboardAnimatable {
    func addOperationToQueue(_ operation: MainThreadOperation) {
        formDelegate?.addOperationToQueue(operation)
    }

    func suspendQueue(_ isSuspended: Bool) {
        formDelegate?.suspendQueue(isSuspended)
    }

    func cancelAllOperations() {
        formDelegate?.cancelAllOperations()
    }

    func elementInspectorFormSectionViewController(_ sectionController: ElementInspectorFormSectionViewController,
                                                   didChangeState newState: UIControl.State,
                                                   from oldState: UIControl.State?)
    {
        animatePanel(animations: { [weak self] in
            guard let self = self else { return }

            sectionController.sectionState = newState

            guard newState == .selected else { return }

            let selectedSections = self.children
                .compactMap { $0 as? ElementInspectorFormSectionViewController }
                .filter { $0.sectionState == .selected }

            for section in selectedSections where section !== sectionController {
                section.sectionState = .normal
            }
        })
    }

    weak var formDelegate: ElementInspectorFormViewControllerDelegate?

    weak var dataSource: ElementInspectorFormViewControllerDataSource?

    var selectedColorPicker: ColorPreviewControl?

    var selectedImagePicker: ImagePreviewControl?

    var selectedOptionSelector: OptionListControl?

    override func loadView() {
        view = (self as? ElementInspectorFormViewController)?.viewCode ?? UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let self = self as? ElementInspectorFormViewController else { return }

        loadSections()

        animateWhenKeyboard(.willChangeFrame) { info in
            self.viewCode.keyboardHeight = info.keyboardFrame.height
            self.viewCode.layoutIfNeeded()
        }
    }

    func loadSections() {
        guard
            let self = self as? ElementInspectorFormViewController,
            let dataSource = dataSource
        else { return }

        dataSource.sections.enumerated().forEach { sectionIndex, section in
            if let title = section.title {
                let sectionHeaderView = SectionHeader(
                    title: title,
                    titleFont: .headline,
                    margins: .init(insets: ElementInspector.appearance.horizontalMargins)
                ).then {
                    $0.alpha = 0.5
                }

                self.viewCode.contentView.addArrangedSubview(sectionHeaderView)
            }

            for (row, viewModel) in section.viewModels.enumerated() {
                let indexPath = IndexPath(row: row, section: sectionIndex)

                let Type = dataSource.typeForRow(at: indexPath) ?? ElementInspectorFormSectionContentView.self
                let viewCode = Type.create()
                viewCode.separatorStyle = indexPath.isFirst ? .none : .top

                let sectionViewController = ElementInspectorFormSectionViewController.create(
                    viewModel: viewModel,
                    viewCode: viewCode
                ).then {
                    $0.sectionState = indexPath.isFirst ? .selected : .normal
                    $0.delegate = self
                }

                addChild(sectionViewController)

                self.viewCode.contentView.addArrangedSubview(sectionViewController.view)

                sectionViewController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
                sectionViewController.didMove(toParent: self)
            }
        }
    }

    func selectImage(_ image: UIImage?) {
        selectedImagePicker?.updateSelectedImage(image)
    }

    func selectColor(_ color: UIColor) {
        selectedColorPicker?.updateSelectedColor(color)
    }

    func selectOptionAtIndex(_ index: Int?) {
        selectedOptionSelector?.updateSelectedIndex(index)
    }

    func finishColorSelection() {
        selectedColorPicker = nil
    }

    func finishOptionSelction() {
        selectedOptionSelector = nil
    }

    func animatePanel(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration * 2,
            delay: 0.05,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
            animations: animations,
            completion: completion
        )
    }

    // MARK: - ElementInspectorFormSectionViewControllerDelegate

    func elementInspectorFormSectionViewController(_ sectionController: ElementInspectorFormSectionViewController,
                                                   willUpdate property: InspectorElementViewModelProperty) {}

    func elementInspectorFormSectionViewController(_ sectionController: ElementInspectorFormSectionViewController,
                                                   didUpdate property: InspectorElementViewModelProperty) {
        let updateOperation = MainThreadOperation(name: "update sections") { [weak self] in
            self?.children.forEach {
                guard let sectionViewController = $0 as? ElementInspectorFormSectionViewController else {
                    return
                }

                sectionViewController.updateValues()
            }
        }

        formDelegate?.addOperationToQueue(updateOperation)
    }

    func elementInspectorFormSectionViewController(_ sectionController: ElementInspectorFormSectionViewController,
                                                   didChangeState newState: UIControl.State,
                                                   from oldState: UIControl.State) {
        animatePanel(
            animations: { [weak self] in
                guard let self = self else { return }

                let selectedSections: [ElementInspectorFormSectionViewController] = self.children
                    .compactMap { $0 as? ElementInspectorFormSectionViewController }
                    .filter { $0.sectionState == .selected }

                for section in selectedSections {
                    section.sectionState = .normal
                }

                sectionController.sectionState = .selected
            },
            completion: nil
        )
    }

    func elementInspectorFormSectionViewController(_ sectionController: ElementInspectorFormSectionViewController,
                                                   didTap imagePicker: ImagePreviewControl) {
        selectedImagePicker = imagePicker

        guard let self = self as? ElementInspectorFormViewController else { return }

        self.formDelegate?.elementInspectorViewController(self, didTap: imagePicker)
    }

    func elementInspectorFormSectionViewController(_ sectionController: ElementInspectorFormSectionViewController,
                                                   didTap colorPicker: ColorPreviewControl) {
        selectedColorPicker = colorPicker

        guard let self = self as? ElementInspectorFormViewController else { return }

        self.formDelegate?.elementInspectorViewController(self, didTap: colorPicker)
    }

    func elementInspectorFormSectionViewController(_ sectionController: ElementInspectorFormSectionViewController,
                                                   didTap optionSelector: OptionListControl) {
        selectedOptionSelector = optionSelector

        guard let self = self as? ElementInspectorFormViewController else { return }

        self.formDelegate?.elementInspectorViewController(self, didTap: optionSelector)
    }
}

private extension IndexPath {
    var isFirst: Bool {
        row == .zero && section == .zero
    }
}
