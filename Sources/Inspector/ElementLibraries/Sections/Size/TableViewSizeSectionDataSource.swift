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

        var properties: [InspectorElementProperty] {
            guard let tableView = tableView else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .rowHeight:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { tableView.rowHeight },
                        range: { UITableView.automaticDimension...Double.infinity },
                        stepValue: { 1 }
                    ) { rowHeight in
                        tableView.rowHeight = rowHeight
                    }
                case .estimatedRowHeight:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { tableView.estimatedRowHeight },
                        range: { UITableView.automaticDimension...Double.infinity },
                        stepValue: { 1 }
                    ) { estimatedRowHeight in
                        tableView.estimatedRowHeight = estimatedRowHeight
                    }
                case .separator0,
                     .separator1:
                    return .separator

                case .sectionsGroup,
                     .contentViewGroup:
                    return .group(title: property.rawValue)

                case .sectionHeaderHeight:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { tableView.sectionHeaderHeight },
                        range: { UITableView.automaticDimension...Double.infinity },
                        stepValue: { 1 }
                    ) { sectionHeaderHeight in
                        tableView.sectionHeaderHeight = sectionHeaderHeight
                    }
                case .estimatedSectionHeaderHeight:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { tableView.estimatedSectionHeaderHeight },
                        range: { UITableView.automaticDimension...Double.infinity },
                        stepValue: { 1 }
                    ) { estimatedSectionHeaderHeight in
                        tableView.estimatedSectionHeaderHeight = estimatedSectionHeaderHeight
                    }
                case .sectionFooterHeight:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { tableView.sectionFooterHeight },
                        range: { UITableView.automaticDimension...Double.infinity },
                        stepValue: { 1 }
                    ) { sectionFooterHeight in
                        tableView.sectionFooterHeight = sectionFooterHeight
                    }
                case .estimatedSectionFooterHeight:
                    return .cgFloatStepper(
                        title: property.rawValue,
                        value: { tableView.estimatedSectionFooterHeight },
                        range: { UITableView.automaticDimension...Double.infinity },
                        stepValue: { 1 }
                    ) { estimatedSectionFooterHeight in
                        tableView.estimatedSectionFooterHeight = estimatedSectionFooterHeight
                    }
                case .insetsContentViewsToSafeArea:
                    return .switch(
                        title: property.rawValue,
                        isOn: { tableView.insetsContentViewsToSafeArea }
                    ) { insetsContentViewsToSafeArea in
                        tableView.insetsContentViewsToSafeArea = insetsContentViewsToSafeArea
                    }
                }
            }
        }
    }
}
