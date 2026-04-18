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

extension DefaultElementSizeLibrary {
    final class TableViewSizeSectionDataSource: InspectorElementSectionDataSource {
        let title: String = "Table View"

        var state: InspectorElementSectionState = .collapsed

        private weak var tableView: UITableView?

        init?(with object: NSObject) {
            guard let tableView = object as? UITableView else { return nil }
            self.tableView = tableView
        }

        private enum Properties: String, Swift.CaseIterable {
            case rowHeight = "Row Height"
            case estimatedRowHeight = "Estimated Row Height"
            case separator0
            case sectionsGroup = "Sections"
            case sectionHeaderHeight = "Header Height"
            case estimatedSectionHeaderHeight = "Estimated Header Height"
            case sectionFooterHeight = "Footer Height"
            case estimatedSectionFooterHeight = "Estimated Footer Height"
            case separator1
            case contentViewGroup = "Content View"
            case insetsContentViewsToSafeArea = "Insets Content Views"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let tableView else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .rowHeight:
                    numericBinding(
                        id: "row-height",
                        title: property.rawValue,
                        value: { Double(tableView.rowHeight) },
                        setter: { tableView.rowHeight = CGFloat($0) }
                    )
                case .estimatedRowHeight:
                    numericBinding(
                        id: "estimated-row-height",
                        title: property.rawValue,
                        value: { Double(tableView.estimatedRowHeight) },
                        setter: { tableView.estimatedRowHeight = CGFloat($0) }
                    )
                case .separator0,
                     .separator1:
                    .init(
                        descriptor: .init(
                            id: property.rawValue,
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .sectionsGroup,
                     .contentViewGroup:
                    .init(
                        descriptor: .init(
                            id: property.rawValue,
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .sectionHeaderHeight:
                    numericBinding(
                        id: "section-header-height",
                        title: property.rawValue,
                        value: { Double(tableView.sectionHeaderHeight) },
                        setter: { tableView.sectionHeaderHeight = CGFloat($0) }
                    )
                case .estimatedSectionHeaderHeight:
                    numericBinding(
                        id: "estimated-section-header-height",
                        title: property.rawValue,
                        value: { Double(tableView.estimatedSectionHeaderHeight) },
                        setter: { tableView.estimatedSectionHeaderHeight = CGFloat($0) }
                    )
                case .sectionFooterHeight:
                    numericBinding(
                        id: "section-footer-height",
                        title: property.rawValue,
                        value: { Double(tableView.sectionFooterHeight) },
                        setter: { tableView.sectionFooterHeight = CGFloat($0) }
                    )
                case .estimatedSectionFooterHeight:
                    numericBinding(
                        id: "estimated-section-footer-height",
                        title: property.rawValue,
                        value: { Double(tableView.estimatedSectionFooterHeight) },
                        setter: { tableView.estimatedSectionFooterHeight = CGFloat($0) }
                    )
                case .insetsContentViewsToSafeArea:
                    .init(
                        descriptor: .init(
                            id: "insets-content-views-to-safe-area",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(tableView.insetsContentViewsToSafeArea) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            tableView.insetsContentViewsToSafeArea = isOn
                        }
                    )
                }
            }
        }

        private func numericBinding(
            id: String,
            title: String,
            value: @escaping () -> Double,
            setter: @escaping (Double) -> Void
        ) -> InspectorPropertyBinding {
            .init(
                descriptor: .init(
                    id: id,
                    title: title,
                    kind: .stepper,
                    value: .number(.init(min: Double(UITableView.automaticDimension), step: 1, isDecimal: true)),
                    editability: .editable
                ),
                read: { .number(value()) },
                write: { newValue in
                    guard case let .number(updated) = newValue else { return }
                    setter(updated)
                }
            )
        }
    }
}
