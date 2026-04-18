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

internal import Coordinator
import InspectorContract
import SwiftUI
import UIKit

extension DefaultElementAttributesLibrary {
    final class NavigationBarAppearanceAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let kind: Kind

        weak var appearance: UINavigationBarAppearance?

        init?(with object: NSObject, _ kind: Kind) {
            guard
                let navigationBar = object as? UINavigationBar,
                let appearance = kind.appearance(from: navigationBar)
            else {
                return nil
            }
            self.kind = kind
            self.appearance = appearance
        }

        var title: String {
            kind.description.string(appending: "Appearance")
        }

        private enum Property: String, Swift.CaseIterable {
            case information
            case iOS15_behaviorWarning
            case backgroundEffect = "Blur Style"
            case backgroundColor = "Background"
            case backgroundImage = "Image"
            case backgroundImageContentMode = "Content Mode"
            case shadowColor = "Shadow Color"
            case shadowImage = "Shadow Image"
            case separator0
            case titleOffset = "Title Offset"
            case separator1

            case titleGroup = "Title Attributes"
            case titleFontName = "Title Font Name"
            case titleFontSize = "Title Font Size"
            case titleColor = "Title Color"
            case titleShadow = "Title Shadow"
            case titleShadowOffset = "Title Shadow Offset"

            case largeTitleGroup = "Large Title Attributes"
            case largeTitleFontName = "Large Title Font Name"
            case largeTitleFontSize = "Large Title Font Size"
            case largeTitleColor = "Large Title Color"
            case largeTitleShadow = "Large Title Shadow"
            case largeTitleShadowOffset = "Large Title Shadow Offset"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let appearance else { return [] }

            return Property.allCases.compactMap { property in
                binding(for: property, appearance: appearance)
            }
        }

        private func binding(for property: Property, appearance: UINavigationBarAppearance) -> InspectorPropertyBinding? {
            let id = property.rawValue.isEmpty ? "separator" : property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased()
            switch property {
            case .information:
                return noteBinding(id: id, property: property, icon: .info, text: kind.message)
            case .iOS15_behaviorWarning:
                switch kind {
                case .scrollEdge:
                    return noteBinding(id: id, property: property, icon: .warning, text: "Starting iOS 15 when this property is nil, the navigation bar's background will become transparent when scrolled to the top.")
                case .compactScrollEdge:
                    return noteBinding(id: id, property: property, icon: .warning, text: "Starting iOS 15 when this property is nil, the navigation bar's background will become transparent when scrolled to the top in a vertically compact orientation.")
                default:
                    return nil
                }
            case .backgroundEffect:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .options, value: .selection(.init(options: UIBlurEffect.Style.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable),
                    read: {
                        guard let style = appearance.backgroundEffect?.style else { return .selection(nil) }
                        return .selection(UIBlurEffect.Style.allCases.firstIndex(of: style))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue else { return }
                        if let index, (0..<UIBlurEffect.Style.allCases.count).contains(index) {
                            appearance.backgroundEffect = UIBlurEffect(style: UIBlurEffect.Style.allCases[index])
                        } else {
                            appearance.backgroundEffect = nil
                        }
                    },
                    runtimePresentation: .init(emptyTitle: "None")
                )
            case .backgroundColor:
                return colorBinding(id: id, title: property.rawValue, emptyTitle: Texts.default, read: { appearance.backgroundColor }, write: { appearance.backgroundColor = $0 })
            case .backgroundImage:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .preview, value: .none, editability: .editable), read: { .image(appearance.backgroundImage) }, write: { newValue in guard case let .image(v) = newValue else { return }; appearance.backgroundImage = v })
            case .backgroundImageContentMode:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .options, value: .selection(.init(options: UIView.ContentMode.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable), read: { .selection(UIView.ContentMode.allCases.firstIndex(of: appearance.backgroundImageContentMode)) }, write: { newValue in guard case let .selection(index) = newValue, let index else { return }; appearance.backgroundImageContentMode = UIView.ContentMode.allCases[index] })
            case .shadowColor:
                return colorBinding(id: id, title: property.rawValue, emptyTitle: Texts.default, read: { appearance.shadowColor }, write: { appearance.shadowColor = $0 })
            case .shadowImage:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .preview, value: .none, editability: .editable), read: { .image(appearance.shadowImage) }, write: { newValue in guard case let .image(v) = newValue else { return }; appearance.shadowImage = v })
            case .separator0, .separator1:
                return .init(descriptor: .init(id: id, title: "", kind: .separator, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
            case .titleOffset:
                return nil
            case .titleGroup, .largeTitleGroup:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .group, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
            case .titleFontName:
                return fontNameBinding(id: id, title: property.rawValue, readFont: { appearance.titleTextAttributes[.font] as? UIFont }, writeFont: { font in appearance.titleTextAttributes[.font] = font })
            case .titleFontSize:
                return fontSizeBinding(id: id, title: property.rawValue, readFont: { appearance.titleTextAttributes[.font] as? UIFont }, writeFont: { font in appearance.titleTextAttributes[.font] = font })
            case .titleColor:
                return colorBinding(id: id, title: property.rawValue, emptyTitle: Texts.default, read: { appearance.titleTextAttributes[.foregroundColor] as? UIColor }, write: { appearance.titleTextAttributes[.foregroundColor] = $0 })
            case .titleShadow:
                return colorBinding(id: id, title: property.rawValue, emptyTitle: Texts.default, read: { (appearance.titleTextAttributes[.shadow] as? NSShadow)?.shadowColor as? UIColor }, write: { color in self.ensureTitleShadow(for: &appearance.titleTextAttributes).shadowColor = color })
            case .titleShadowOffset:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .preview, value: .size, editability: .editable), read: { .size((appearance.titleTextAttributes[.shadow] as? NSShadow)?.shadowOffset ?? .zero) }, write: { newValue in guard case let .size(v) = newValue else { return }; self.ensureTitleShadow(for: &appearance.titleTextAttributes).shadowOffset = v })
            case .largeTitleFontName:
                return fontNameBinding(id: id, title: property.rawValue, readFont: { appearance.largeTitleTextAttributes[.font] as? UIFont }, writeFont: { font in appearance.largeTitleTextAttributes[.font] = font })
            case .largeTitleFontSize:
                return fontSizeBinding(id: id, title: property.rawValue, readFont: { appearance.largeTitleTextAttributes[.font] as? UIFont }, writeFont: { font in appearance.largeTitleTextAttributes[.font] = font })
            case .largeTitleColor:
                return colorBinding(id: id, title: property.rawValue, emptyTitle: Texts.default, read: { appearance.largeTitleTextAttributes[.foregroundColor] as? UIColor }, write: { appearance.largeTitleTextAttributes[.foregroundColor] = $0 })
            case .largeTitleShadow:
                return colorBinding(id: id, title: property.rawValue, emptyTitle: Texts.default, read: { (appearance.largeTitleTextAttributes[.shadow] as? NSShadow)?.shadowColor as? UIColor }, write: { color in self.ensureTitleShadow(for: &appearance.largeTitleTextAttributes).shadowColor = color })
            case .largeTitleShadowOffset:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .preview, value: .size, editability: .editable), read: { .size((appearance.largeTitleTextAttributes[.shadow] as? NSShadow)?.shadowOffset ?? .zero) }, write: { newValue in guard case let .size(v) = newValue else { return }; self.ensureTitleShadow(for: &appearance.largeTitleTextAttributes).shadowOffset = v })
            }
        }

        private func noteBinding(id: String, property: Property, icon: InspectorElemenPropertyNoteIcon, text: String) -> InspectorPropertyBinding {
            let style: InspectorNoteStyle = icon == .warning ? .warning : .info
            return .init(descriptor: .init(id: id, title: property.rawValue, kind: .note, value: .none, editability: .readOnly, presentation: .init(subtitle: text, noteStyle: style)), read: { .none }, write: nil, refreshHint: .none)
        }

        private func colorBinding(id: String, title: String, emptyTitle: String, read: @escaping () -> UIColor?, write: @escaping (UIColor?) -> Void) -> InspectorPropertyBinding {
            .init(descriptor: .init(id: id, title: title, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(read()) }, write: { newValue in guard case let .color(v) = newValue else { return }; write(v) }, runtimePresentation: .init(emptyTitle: emptyTitle))
        }

        private func fontNameBinding(id: String, title: String, readFont: @escaping () -> UIFont?, writeFont: @escaping (UIFont?) -> Void) -> InspectorPropertyBinding {
            .init(
                descriptor: .init(id: id, title: title, kind: .options, value: .selection(.init(options: FontReference.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable, presentation: .init(axis: .vertical)),
                read: {
                    let fontName = readFont()?.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
                    return .selection(FontReference.firstIndex(of: fontName))
                },
                write: { newValue in
                    guard case let .selection(index) = newValue, let index else { return }
                    let size = readFont()?.pointSize ?? UIFont.systemFontSize
                    writeFont(FontReference.font(at: index, size: size))
                },
                runtimePresentation: .init(selectionOptionIcons: FontReference.allCases.map(\.icon))
            )
        }

        private func fontSizeBinding(id: String, title: String, readFont: @escaping () -> UIFont?, writeFont: @escaping (UIFont?) -> Void) -> InspectorPropertyBinding {
            .init(
                descriptor: .init(id: id, title: title, kind: .stepper, value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)), editability: .editable),
                read: { .number(Double(readFont()?.pointSize ?? UIFont.systemFontSize)) },
                write: { newValue in
                    guard case let .number(value) = newValue, let font = readFont() else { return }
                    writeFont(font.withSize(CGFloat(value)))
                }
            )
        }

        private func ensureTitleShadow(for attributes: inout [NSAttributedString.Key: Any]) -> NSShadow {
            if let shadow = attributes[.shadow] as? NSShadow {
                return shadow
            }
            let shadow = NSShadow()
            attributes[.shadow] = shadow
            return shadow
        }
    }
}

// MARK: - TitleAttribute

extension DefaultElementAttributesLibrary.NavigationBarAppearanceAttributesSectionDataSource {
    private enum TitleAttribute: String, Swift.CaseIterable {
        case groupTitle
        case fontName = "Title Font Name"
        case fontSize = "Title Font Size"
        case color = "Title Color"
        case shadow = "Title Shadow"
        case shadowOffset = "Shadow Offset"
    }
}

// MARK: - `Type`

extension DefaultElementAttributesLibrary.NavigationBarAppearanceAttributesSectionDataSource {
    enum Kind: CustomStringConvertible {
        case standard, compact, scrollEdge, compactScrollEdge

        func appearance(from navigationBar: UINavigationBar) -> UINavigationBarAppearance? {
            switch self {
            case .standard:
                return navigationBar.standardAppearance
            case .compact:
                return navigationBar.compactAppearance
            case .scrollEdge:
                return navigationBar.scrollEdgeAppearance
            case .compactScrollEdge:
                return navigationBar.compactScrollEdgeAppearance
            }
        }

        var description: String {
            switch self {
            case .standard:
                "Standard"
            case .compact:
                "Compact"
            case .scrollEdge:
                "Scroll Edge"
            case .compactScrollEdge:
                "Compact Scroll Edge"
            }
        }

        var message: String {
            switch self {
            case .standard:
                "The appearance settings for a standard height navigation bar."
            case .compact:
                "The appearance settings for a compact height navigation bar."
            case .scrollEdge:
                "The appearance settings for the navigation bar when content is scrolled to the top."
            case .compactScrollEdge:
                "The appearance settings for a compact-height navigation bar when content is scrolled to the top."
            }
        }

        var infoNote: InspectorElementProperty {
            .infoNote(icon: .info, text: message)
        }

        var warning: InspectorElementProperty? {
            switch self {
            case .scrollEdge:
                return .infoNote(
                    icon: .warning,
                    text: "Starting iOS 15 when this property is nil, the navigation bar's background will become transparent when scrolled to the top."
                )

            case .compactScrollEdge:
                return .infoNote(
                    icon: .warning,
                    text: "Starting iOS 15 when this property is nil, the navigation bar's background will become transparent when scrolled to the top in a vertically compact orientation."
                )

            default:
                return .none
            }
        }
    }
}
