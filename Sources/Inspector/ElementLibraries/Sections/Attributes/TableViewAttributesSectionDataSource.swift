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
    final class TableViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        let title: String = "Table View"

        var state: InspectorElementSectionState = .collapsed

        private weak var tableView: UITableView?

        init?(with object: NSObject) {
            guard let tableView = object as? UITableView else { return nil }
            self.tableView = tableView
        }

        private enum Properties: String, Swift.CaseIterable {
            case style = "Style"
            case separatorStyle = "Separator"
            case separatorColor = "Color"
            case divider
            case separatorInset = "Separator Inset"
            case selection = "Selection"
            case editingSelection = "Editing"
            case isSpringLoaded = "Spring loaded drag n' drop"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let tableView else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .style:
                    return .init(
                        descriptor: .init(
                            id: "style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UITableView.Style.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .readOnly
                        ),
                        read: { .selection(UITableView.Style.allCases.firstIndex(of: tableView.style)) },
                        write: nil,
                        refreshHint: .none
                    )
                case .separatorStyle:
                    return .init(
                        descriptor: .init(
                            id: "separator-style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UITableViewCell.SeparatorStyle.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UITableViewCell.SeparatorStyle.allCases.firstIndex(of: tableView.separatorStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            tableView.separatorStyle = UITableViewCell.SeparatorStyle.allCases[newIndex]
                        }
                    )
                case .separatorColor:
                    return .init(
                        descriptor: .init(
                            id: "separator-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(tableView.separatorColor) },
                        write: { newValue in
                            guard case let .color(color) = newValue else { return }
                            tableView.separatorColor = color
                        }
                    )
                case .divider:
                    return .init(
                        descriptor: .init(
                            id: "divider",
                            title: "Divider",
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .separatorInset:
                    return .init(
                        descriptor: .init(
                            id: "separator-inset",
                            title: property.rawValue,
                            kind: .preview,
                            value: .edgeInsets,
                            editability: .editable
                        ),
                        read: { .edgeInsets(tableView.separatorInset) },
                        write: { newValue in
                            guard case let .edgeInsets(insets) = newValue else { return }
                            tableView.separatorInset = insets
                        }
                    )
                case .selection:
                    return .init(
                        descriptor: .init(
                            id: "selection",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: [
                                    .init(id: "0", title: "None"),
                                    .init(id: "1", title: "Single Selection"),
                                    .init(id: "2", title: "Multiple Selection")
                                ], allowsNil: true)
                            ),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: {
                            if tableView.allowsMultipleSelection { return .selection(2) }
                            if tableView.allowsSelection { return .selection(1) }
                            return .selection(0)
                        },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            switch index {
                            case 0:
                                tableView.allowsSelection = false
                                tableView.allowsMultipleSelection = false
                            case 1:
                                tableView.allowsSelection = true
                                tableView.allowsMultipleSelection = false
                            case 2:
                                tableView.allowsSelection = true
                                tableView.allowsMultipleSelection = true
                            default:
                                break
                            }
                        }
                    )
                case .editingSelection:
                    return .init(
                        descriptor: .init(
                            id: "editing-selection",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: [
                                    .init(id: "0", title: "None"),
                                    .init(id: "1", title: "Single Selection"),
                                    .init(id: "2", title: "Multiple Selection")
                                ], allowsNil: true)
                            ),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: {
                            if tableView.allowsMultipleSelectionDuringEditing { return .selection(2) }
                            if tableView.allowsSelectionDuringEditing { return .selection(1) }
                            return .selection(0)
                        },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            switch index {
                            case 0:
                                tableView.allowsSelectionDuringEditing = false
                                tableView.allowsMultipleSelectionDuringEditing = false
                            case 1:
                                tableView.allowsSelectionDuringEditing = true
                                tableView.allowsMultipleSelectionDuringEditing = false
                            case 2:
                                tableView.allowsSelectionDuringEditing = true
                                tableView.allowsMultipleSelectionDuringEditing = true
                            default:
                                break
                            }
                        }
                    )
                case .isSpringLoaded:
                    return .init(
                        descriptor: .init(
                            id: "is-spring-loaded",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(tableView.isSpringLoaded) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            tableView.isSpringLoaded = isOn
                        }
                    )
                }
            }
        }
    }
}

extension UITableViewCell.SeparatorStyle: CaseIterable {
    typealias AllCases = [UITableViewCell.SeparatorStyle]

    static var allCases: [UITableViewCell.SeparatorStyle] {
        [.none, .singleLine]
    }
}

extension UITableViewCell.SeparatorStyle: CustomStringConvertible {
    var description: String {
        switch self {
        case .none:
            return "None"
        case .singleLine:
            return "Single Line"
        case .singleLineEtched:
            return "Etched Single Line"
        @unknown default:
            return "Unknown"
        }
    }
}

extension UITableView.Style: CaseIterable {
    typealias AllCases = [UITableView.Style]

    static let allCases: [UITableView.Style] = [.plain, .grouped, .insetGrouped]
}

extension UITableView.Style: CustomStringConvertible {
    var description: String {
        switch self {
        case .plain:
            return "Plain"
        case .grouped:
            return "Grouped"
        case .insetGrouped:
            return "Inset Grouped"
        @unknown default:
            return "Unknown"
        }
    }
}
