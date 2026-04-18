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

import InspectorContract
import UIKit

extension DefaultElementAttributesLibrary {
    final class ViewControllerAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "View Controller"

        private weak var viewController: UIViewController?

        private lazy var isInitialViewController: Bool? = {
            guard
                let viewController,
                let initialViewController = viewController.storyboard?.instantiateInitialViewController()
            else {
                return nil
            }

            return type(of: initialViewController) == type(of: viewController)
        }()

        init?(with object: NSObject) {
            guard let viewController = object as? UIViewController else {
                return nil
            }

            self.viewController = viewController
        }

        private enum Property: String, Swift.CaseIterable {
            case title = "Title"
            case initialViewController = "Is Initial View Controller"
            case separator0
            case groupLayout = "Layout"
            case hidesBottomBarWhenPushed = "Hide Bottom Bar on Push"
            case groupExtendEdges = "Extend Edges"
            case topBars = "Under Top Bars"
            case bottomBars = "Under Bottom Bars"
            case opaqueBars = "Under Opaque Bars"
            case separator1
            case modalTransitionStyle = "Transition Style"
            case presentationStyle = "Presentation"
            case definesPresentationContext = "Defines Context"
            case providesPresentationContextTransitionStyle = "Provides Context"
            case contentSize = "Preferred Content Size"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let viewController else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .separator0, .separator1:
                    return .init(
                        descriptor: .init(id: property.rawValue.isEmpty ? "separator" : property.rawValue, title: "", kind: .separator, value: .none, editability: .readOnly),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .groupLayout, .groupExtendEdges:
                    return .init(
                        descriptor: .init(id: property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(), title: property.rawValue, kind: .group, value: .none, editability: .readOnly),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .title:
                    return .init(
                        descriptor: .init(
                            id: "title",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: nil, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .horizontal)
                        ),
                        read: { .string(viewController.title) },
                        write: { newValue in
                            guard case let .string(title) = newValue else { return }
                            viewController.title = title
                        }
                    )
                case .initialViewController:
                    guard let isInitialViewController else { return nil }
                    return .init(
                        descriptor: .init(id: "is-initial-view-controller", title: property.rawValue, kind: .toggle, value: .bool, editability: .readOnly),
                        read: { .bool(isInitialViewController) },
                        write: nil,
                        refreshHint: .none
                    )
                case .hidesBottomBarWhenPushed:
                    return .init(
                        descriptor: .init(id: "hides-bottom-bar-when-pushed", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                        read: { .bool(viewController.hidesBottomBarWhenPushed) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            viewController.hidesBottomBarWhenPushed = isEnabled
                        }
                    )
                case .topBars:
                    return .init(
                        descriptor: .init(id: "under-top-bars", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                        read: { .bool(viewController.edgesForExtendedLayout.contains(.top)) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            if isEnabled { viewController.edgesForExtendedLayout.insert(.top) }
                            else { viewController.edgesForExtendedLayout.remove(.top) }
                        }
                    )
                case .bottomBars:
                    return .init(
                        descriptor: .init(id: "under-bottom-bars", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                        read: { .bool(viewController.edgesForExtendedLayout.contains(.bottom)) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            if isEnabled { viewController.edgesForExtendedLayout.insert(.bottom) }
                            else { viewController.edgesForExtendedLayout.remove(.bottom) }
                        }
                    )
                case .opaqueBars:
                    return .init(
                        descriptor: .init(id: "under-opaque-bars", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                        read: { .bool(viewController.extendedLayoutIncludesOpaqueBars) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            viewController.extendedLayoutIncludesOpaqueBars = isEnabled
                        }
                    )
                case .modalTransitionStyle:
                    return .init(
                        descriptor: .init(
                            id: "modal-transition-style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: UIModalTransitionStyle.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .horizontal)
                        ),
                        read: { .selection(UIModalTransitionStyle.allCases.firstIndex(of: viewController.modalTransitionStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            viewController.modalTransitionStyle = UIModalTransitionStyle.allCases[index]
                        }
                    )
                case .presentationStyle:
                    return .init(
                        descriptor: .init(
                            id: "modal-presentation-style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: UIModalPresentationStyle.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .horizontal)
                        ),
                        read: { .selection(UIModalPresentationStyle.allCases.firstIndex(of: viewController.modalPresentationStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            viewController.modalPresentationStyle = UIModalPresentationStyle.allCases[index]
                        }
                    )
                case .definesPresentationContext:
                    return .init(
                        descriptor: .init(id: "defines-presentation-context", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                        read: { .bool(viewController.definesPresentationContext) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            viewController.definesPresentationContext = isEnabled
                        }
                    )
                case .providesPresentationContextTransitionStyle:
                    return .init(
                        descriptor: .init(id: "provides-presentation-context-transition-style", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                        read: { .bool(viewController.providesPresentationContextTransitionStyle) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            viewController.providesPresentationContextTransitionStyle = isEnabled
                        }
                    )
                case .contentSize:
                    return .init(
                        descriptor: .init(id: "preferred-content-size", title: property.rawValue, kind: .preview, value: .size, editability: .editable),
                        read: { .size(viewController.preferredContentSize) },
                        write: { newValue in
                            guard case let .size(size) = newValue else { return }
                            viewController.preferredContentSize = size
                        }
                    )
                }
            }
        }
    }
}
