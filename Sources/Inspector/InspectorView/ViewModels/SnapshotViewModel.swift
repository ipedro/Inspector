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

extension HierarchyInspectorViewModel {
    final class SnapshotViewModel: NSObject, HierarchyInspectorSectionViewModelProtocol {
        let shouldAnimateKeyboard: Bool = true

        private struct Details: HierarchyInspectorReferenceSummaryCellViewModelProtocol {
            let title: String?
            var isEnabled: Bool
            let subtitle: String?
            let image: UIImage?
            let depth: Int
            let element: ViewHierarchyElementReference

            init(with element: ViewHierarchyElementReference, isEnabled: Bool) {
                self.title = element.displayName
                self.isEnabled = isEnabled
                self.subtitle = element.shortElementDescription
                self.depth = element.depth
                self.element = element
                self.image = element.iconImage?
                    .resized(Inspector.sharedInstance.appearance.actionIconSize)
            }
        }

        private struct SearchQueryItem: ExpirableProtocol {
            let query: String
            let expirationDate: Date = Date().addingTimeInterval(5)
            let results: [Details]
        }

        var searchQuery: String? {
            didSet {
                if oldValue != searchQuery {
                    debounce(#selector(loadData), delay: .short)
                }
            }
        }

        private var queryStore: [String: SearchQueryItem] = [:]

        let snapshot: ViewHierarchySnapshot

        private var currentSearchResults = [Details]()

        init(snapshot: ViewHierarchySnapshot) {
            self.snapshot = snapshot
        }

        var isEmpty: Bool { currentSearchResults.isEmpty }

        let numberOfSections = 1

        func selectRow(at indexPath: IndexPath) -> InspectorCommand? {
            guard (0 ..< currentSearchResults.count).contains(indexPath.row) else {
                return nil
            }
            let element = currentSearchResults[indexPath.row].element

            return .inspect(element)
        }

        func isRowEnabled(at indexPath: IndexPath) -> Bool {
            currentSearchResults[indexPath.row].isEnabled
        }

        func numberOfRows(in section: Int) -> Int {
            currentSearchResults.count
        }

        func titleForHeader(in section: Int) -> String? {
            Texts.allResults(count: currentSearchResults.count, in: snapshot.root.displayName)
        }

        func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
            .element(currentSearchResults[indexPath.row])
        }

        @objc func loadData() {
            currentSearchResults = {
                guard let key = searchQuery else {
                    return []
                }

                if let searchQueryItem = queryStore[key], searchQueryItem.isValid {
                    return searchQueryItem.results
                }

                if key == Inspector.sharedInstance.configuration.showAllViewSearchQuery {
                    let results = snapshot.root.viewHierarchy.map {
                        Details(with: $0, isEnabled: true)
                    }

                    let queryItem = SearchQueryItem(
                        query: key,
                        results: results
                    )

                    queryStore[key] = queryItem

                    return queryItem.results
                }

                let results: [Details] = snapshot.root.viewHierarchy.compactMap { element in
                    guard (element.displayName + element.className).localizedCaseInsensitiveContains(key) else { return nil }
                    return Details(with: element, isEnabled: true)
                }

                let queryItem = SearchQueryItem(
                    query: key,
                    results: results
                )

                queryStore[key] = queryItem

                return queryItem.results
            }()
        }
    }
}
