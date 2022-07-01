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

@available(*, deprecated, renamed: "InspectorElementProperty")
public typealias InspectorElementViewModelProperty = InspectorElementProperty

public enum InspectorElementProperty {
    public struct PreviewTarget {
        internal let reference: ViewHierarchyElement

        public init(view: UIView) {
            reference = ViewHierarchyElement(with: view, iconProvider: .default)
        }
    }

    case preview(target: PreviewTarget)

    case colorPicker(title: String,
                     emptyTitle: String = "No color",
                     color: ColorProvider,
                     handler: ColorHandler? = .none)

    case group(title: String, subtitle: String? = nil)

    case infoNote(icon: InspectorElemenPropertyNoteIcon? = .info,
                  title: String? = nil,
                  text: String? = nil)

    case separator

    case imagePicker(title: String,
                     image: ImageProvider,
                     handler: ImageHandler? = .none)

    case optionsList(title: String,
                     emptyTitle: String = "Unspecified",
                     axis: NSLayoutConstraint.Axis = .horizontal,
                     options: [(title: Swift.CustomStringConvertible, icon: UIImage?)],
                     selectedIndex: SelectionProvider,
                     handler: SelectionHandler? = .none)

    static func optionsList(title: String,
                            emptyTitle: String = "Unspecified",
                            axis: NSLayoutConstraint.Axis = .horizontal,
                            options: [String],
                            selectedIndex: @escaping SelectionProvider,
                            handler: SelectionHandler? = .none) -> InspectorElementProperty
    {
        .optionsList(
            title: title,
            emptyTitle: emptyTitle,
            axis: axis,
            options: options.map { (title: $0, icon: .none) },
            selectedIndex: selectedIndex,
            handler: handler
        )
    }

    case textButtonGroup(title: String,
                         axis: NSLayoutConstraint.Axis = .vertical,
                         texts: [String],
                         selectedIndex: SelectionProvider,
                         handler: SelectionHandler? = .none)

    case imageButtonGroup(title: String,
                          axis: NSLayoutConstraint.Axis = .vertical,
                          images: [UIImage],
                          selectedIndex: SelectionProvider,
                          handler: SelectionHandler? = .none)

    case stepper(title: String,
                 value: DoubleProvider,
                 range: DoubleClosedRangeProvider,
                 stepValue: DoubleProvider,
                 isDecimalValue: Bool,
                 handler: DoubleHandler? = .none)

    case textField(title: String,
                   placeholder: String?,
                   axis: NSLayoutConstraint.Axis = .vertical,
                   value: StringProvider,
                   handler: StringHandler? = .none)

    case textView(title: String,
                  placeholder: String?,
                  value: StringProvider,
                  handler: StringHandler? = .none)

    case `switch`(title: String,
                  isOn: BoolProvider,
                  handler: BoolHandler? = .none)

    case cgRect(title: String,
                rect: CGRectProvider,
                handler: CGRectHandler? = .none)

    case cgPoint(title: String,
                 point: CGPointProvider,
                 handler: CGPointHandler? = .none)

    case cgSize(title: String,
                size: CGSizeProvider,
                handler: CGSizeHandler? = .none)

    case uiOffset(title: String,
                  offset: UIOffsetProvider,
                  handler: UIOffsetHandler? = .none)

    case directionalInsets(title: String,
                           insets: NSDirectionalEdgeInsetsProvider,
                           handler: NSDirectionalEdgeInsetsHandler? = .none)

    case edgeInsets(title: String,
                    insets: UIEdgeInsetsProvider,
                    handler: UIEdgeInsetsHandler? = .none)

    @available(*, deprecated, renamed: "switch(title:isOn:handler:)")
    public static func toggleControl(title: String,
                                     isOn: @escaping BoolProvider,
                                     handler: BoolHandler? = .none) -> Self
    {
        .switch(title: title, isOn: isOn, handler: handler)
    }
}

extension InspectorElementProperty {
    var isControl: Bool {
        switch self {
        case .group, .separator, .infoNote:
            return false

        default:
            return true
        }
    }

    var hasHandler: Bool {
        switch self {
        case .stepper(_, _, _, _, _, .some),
             .colorPicker(_, _, _, .some),
             .switch(_, _, .some),
             .textButtonGroup(_, _, _, _, .some),
             .imageButtonGroup(_, _, _, _, .some),
             .optionsList(_, _, _, _, _, .some),
             .textField(_, _, _, _, .some),
             .textView(_, _, _, .some),
             .imagePicker(_, _, .some),
             .cgRect(_, _, .some),
             .cgSize(_, _, .some),
             .uiOffset(_, _, .some),
             .cgPoint(_, _, .some),
             .edgeInsets(_, _, .some),
             .directionalInsets(_, _, .some):
            return true

        case .stepper,
             .colorPicker,
             .switch,
             .textButtonGroup,
             .imageButtonGroup,
             .optionsList,
             .textField,
             .textView,
             .group,
             .separator,
             .imagePicker,
             .cgRect,
             .cgSize,
             .uiOffset,
             .cgPoint,
             .directionalInsets,
             .edgeInsets,
             .infoNote,
             .preview:
            return false
        }
    }
}

// MARK: - Value Handlers

public extension InspectorElementProperty {
    typealias Handler<Value> = (Value) -> Void

    typealias BoolHandler = Handler<Bool>
    typealias CGColorHandler = Handler<CGColor?>
    typealias CGFloatHandler = Handler<CGFloat>
    typealias CGPointHandler = Handler<CGPoint?>
    typealias CGRectHandler = Handler<CGRect?>
    typealias CGSizeHandler = Handler<CGSize?>
    typealias ColorHandler = Handler<UIColor?>
    typealias DoubleHandler = Handler<Double>
    typealias FloatHandler = Handler<Float>
    typealias FontHandler = Handler<UIFont?>
    typealias ImageHandler = Handler<UIImage?>
    typealias IntHandler = Handler<Int>
    typealias NSDirectionalEdgeInsetsHandler = Handler<NSDirectionalEdgeInsets>
    typealias SelectionHandler = Handler<Int?>
    typealias StringHandler = Handler<String?>
    typealias UIEdgeInsetsHandler = Handler<UIEdgeInsets>
    typealias UIOffsetHandler = Handler<UIOffset>
}

// MARK: - Value Providers

public extension InspectorElementProperty {
    typealias Provider<Value> = () -> Value

    typealias BoolProvider = Provider<Bool>
    typealias CGColorProvider = Provider<CGColor?>
    typealias CGFloatClosedRangeProvider = Provider<ClosedRange<CGFloat>>
    typealias CGFloatProvider = Provider<CGFloat>
    typealias CGPointProvider = Provider<CGPoint>
    typealias CGRectProvider = Provider<CGRect>
    typealias CGSizeProvider = Provider<CGSize>
    typealias ColorProvider = Provider<UIColor?>
    typealias DoubleClosedRangeProvider = Provider<ClosedRange<Double>>
    typealias DoubleProvider = Provider<Double>
    typealias FloatClosedRangeProvider = Provider<ClosedRange<Float>>
    typealias FloatProvider = Provider<Float>
    typealias FontProvider = Provider<UIFont?>
    typealias ImageProvider = Provider<UIImage?>
    typealias IntClosedRangeProvider = Provider<ClosedRange<Int>>
    typealias IntProvider = Provider<Int>
    typealias NSDirectionalEdgeInsetsProvider = Provider<NSDirectionalEdgeInsets>
    typealias SelectionProvider = Provider<Int?>
    typealias StringProvider = Provider<String?>
    typealias UIEdgeInsetsProvider = Provider<UIEdgeInsets>
    typealias UIOffsetProvider = Provider<UIOffset>
}
