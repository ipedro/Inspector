import InspectorContract
import UIKit

extension InspectorPropertyBinding {
    var hasHandler: Bool {
        write != nil
    }

    var isControl: Bool {
        switch descriptor.kind {
        case .group, .separator, .note:
            false
        default:
            true
        }
    }

    func makeFormView() -> UIView? {
        let view: UIView?
        switch (descriptor.kind, currentValue()) {
        case let (.toggle, .bool(value)):
            view = ToggleControl(title: descriptor.title, isOn: value)
        case let (.stepper, .number(value)):
            view = StepperControl(
                title: descriptor.title,
                value: value,
                range: numberRange,
                stepValue: numberConstraints?.step ?? 1,
                isDecimalValue: numberConstraints?.isDecimal ?? false
            )
        case let (.textField, .string(value)):
            view = TextFieldControl(
                title: descriptor.title,
                value: value,
                placeholder: stringConstraints?.placeholder
            )
        case let (.textView, .string(value)):
            view = TextViewControl(
                title: descriptor.title,
                value: value,
                placeholder: stringConstraints?.placeholder
            )
        case let (.options, .selection(index)):
            view = OptionListControl(
                title: descriptor.title,
                options: selectionOptions,
                emptyTitle: selectionEmptyTitle,
                selectedIndex: index
            )
        case let (.textButtons, .selection(index)),
             let (.imageButtons, .selection(index)):
            view = SegmentedControl(
                title: descriptor.title,
                texts: selectionTexts,
                selectedIndex: index
            )
        case let (.color, .color(value)):
            view = ColorPreviewControl(
                title: descriptor.title,
                emptyTitle: selectionEmptyTitle,
                color: value
            )
        case (.group, _):
            view = SectionHeader.attributesInspectorGroup(
                title: descriptor.title,
                subtitle: descriptor.presentation?.subtitle
            )
        case (.separator, _):
            view = SeparatorView(style: .medium).then {
                $0.contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
                    vertical: appearance.horizontalMargins
                )
            }
        case (.note, _):
            view = NoteControl(
                icon: noteIcon,
                title: descriptor.title,
                text: descriptor.presentation?.subtitle
            )
        case let (.preview, .preview(runtimeView)):
            view = LiveViewHierarchyElementThumbnailView(
                with: ViewHierarchyElement(with: runtimeView, iconProvider: .default)
            ).then {
                $0.layer.cornerRadius = appearance.elementInspectorCornerRadius / 2
            }
        case let (.preview, .image(image)):
            view = ImagePreviewControl(title: descriptor.title, image: image)
        case let (.preview, .rect(value)):
            view = RectControl(title: descriptor.title, rect: value)
        case let (.preview, .point(value)):
            view = PointControl(title: descriptor.title, point: value)
        case let (.preview, .size(value)):
            view = SizeControl(title: descriptor.title, size: value)
        case let (.preview, .offset(value)):
            view = OffsetControl(title: descriptor.title, offset: value)
        case let (.preview, .edgeInsets(value)):
            view = EdgeInsetsControl(title: descriptor.title, insets: value)
        case let (.preview, .directionalEdgeInsets(value)):
            view = DirectionalEdgeInsetsControl(title: descriptor.title, insets: value)
        case (.subpanel, _):
            view = nil
        default:
            view = nil
        }

        if let axis = axis, let formControl = view as? BaseFormControl {
            formControl.axis = axis
        }

        return view
    }

    func applyUpdate(from formView: UIView) {
        switch (descriptor.kind, formView) {
        case (.toggle, let toggleControl as ToggleControl):
            apply(.bool(toggleControl.isOn))
        case (.stepper, let stepperControl as StepperControl):
            apply(.number(stepperControl.value))
        case (.textField, let textFieldControl as TextFieldControl):
            apply(.string(textFieldControl.value))
        case (.textView, let textViewControl as TextViewControl):
            apply(.string(textViewControl.value))
        case (.options, let optionSelector as OptionListControl):
            apply(.selection(optionSelector.selectedIndex))
        case (.textButtons, let segmentedControl as SegmentedControl),
             (.imageButtons, let segmentedControl as SegmentedControl):
            apply(.selection(segmentedControl.selectedIndex))
        case (.color, let colorPicker as ColorPreviewControl):
            apply(.color(colorPicker.selectedColor))
        case (.preview, let imagePicker as ImagePreviewControl):
            apply(.image(imagePicker.image))
        case (.preview, let cgRectControl as RectControl):
            apply(.rect(cgRectControl.rect))
        case (.preview, let cgPointControl as PointControl):
            apply(.point(cgPointControl.point))
        case (.preview, let cgSizeControl as SizeControl):
            apply(.size(cgSizeControl.size))
        case (.preview, let uiOffsetControl as OffsetControl):
            apply(.offset(uiOffsetControl.offset))
        case (.preview, let insetsControl as DirectionalEdgeInsetsControl):
            apply(.directionalEdgeInsets(insetsControl.insets))
        case (.preview, let insetsControl as EdgeInsetsControl):
            apply(.edgeInsets(insetsControl.insets))
        case (.separator, _),
             (.group, _),
             (.note, _),
             (.subpanel, _):
            break
        default:
            assertionFailure("unsupported form view update for binding \(descriptor.id)")
        }
    }

    func reload(formView: UIView) {
        switch (descriptor.kind, currentValue(), formView) {
        case let (.toggle, .bool(value), toggleControl as ToggleControl):
            toggleControl.isOn = value
            toggleControl.title = descriptor.title
        case let (.stepper, .number(value), stepperControl as StepperControl):
            stepperControl.title = descriptor.title
            stepperControl.value = value
            stepperControl.range = numberRange
            stepperControl.stepValue = numberConstraints?.step ?? 1
        case let (.textField, .string(value), textFieldControl as TextFieldControl):
            textFieldControl.title = descriptor.title
            textFieldControl.value = value
            textFieldControl.placeholder = stringConstraints?.placeholder
        case let (.textView, .string(value), textViewControl as TextViewControl):
            textViewControl.title = descriptor.title
            textViewControl.value = value
            textViewControl.placeholder = stringConstraints?.placeholder
        case let (.options, .selection(index), optionSelector as OptionListControl):
            optionSelector.title = descriptor.title
            optionSelector.selectedIndex = index
        case let (.textButtons, .selection(index), segmentedControl as SegmentedControl),
             let (.imageButtons, .selection(index), segmentedControl as SegmentedControl):
            segmentedControl.title = descriptor.title
            segmentedControl.selectedIndex = index
        case let (.color, .color(value), colorPicker as ColorPreviewControl):
            colorPicker.title = descriptor.title
            colorPicker.selectedColor = value
        case let (.preview, .image(image), imagePicker as ImagePreviewControl):
            imagePicker.title = descriptor.title
            imagePicker.image = image
        case let (.preview, .rect(value), cgRectControl as RectControl):
            cgRectControl.title = descriptor.title
            cgRectControl.rect = value
        case let (.preview, .point(value), cgPointControl as PointControl):
            cgPointControl.title = descriptor.title
            cgPointControl.point = value
        case let (.preview, .size(value), cgSizeControl as SizeControl):
            cgSizeControl.title = descriptor.title
            cgSizeControl.size = value
        case let (.preview, .offset(value), uiOffsetControl as OffsetControl):
            uiOffsetControl.title = descriptor.title
            uiOffsetControl.offset = value
        case let (.preview, .directionalEdgeInsets(value), directionalInsetsControl as DirectionalEdgeInsetsControl):
            directionalInsetsControl.title = descriptor.title
            directionalInsetsControl.insets = value
        case let (.preview, .edgeInsets(value), edgeInsetsControl as EdgeInsetsControl):
            edgeInsetsControl.title = descriptor.title
            edgeInsetsControl.insets = value
        case let (.preview, .preview(_), thumbnailView as ViewHierarchyElementThumbnailView):
            thumbnailView.updateViews(afterScreenUpdates: false)
        case (.separator, _, _),
             (.group, _, _),
             (.note, _, _),
             (.subpanel, _, _):
            break
        default:
            assertionFailure("unsupported form view reload for binding \(descriptor.id)")
        }
    }

    private var numberConstraints: NumberConstraints? {
        guard case let .number(constraints) = descriptor.value else { return nil }
        return constraints
    }

    private var numberRange: ClosedRange<Double> {
        let min = numberConstraints?.min ?? 0
        let max = numberConstraints?.max ?? Double.infinity
        return min...max
    }

    private var stringConstraints: StringConstraints? {
        guard case let .string(constraints) = descriptor.value else { return nil }
        return constraints
    }

    private var selectionConstraints: SelectionConstraints? {
        guard case let .selection(constraints) = descriptor.value else { return nil }
        return constraints
    }

    private var selectionTexts: [String] {
        selectionConstraints?.options.map { $0.title } ?? []
    }

    private var selectionOptions: [OptionListControl.Option] {
        selectionTexts.map { ($0, nil) }
    }

    private var selectionEmptyTitle: String {
        descriptor.presentation?.subtitle ?? "None"
    }

    private var noteIcon: InspectorElemenPropertyNoteIcon? {
        switch descriptor.presentation?.noteStyle {
        case .warning:
            .warning
        case .info:
            .info
        case .none:
            .none
        }
    }

    private var appearance: ElementInspectorAppearance {
        Inspector.sharedInstance.appearance.elementInspector
    }

    private var axis: NSLayoutConstraint.Axis? {
        switch descriptor.presentation?.axis {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        case .none:
            .none
        }
    }
}
