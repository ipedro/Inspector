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
    final class SnapshotViewModel: HierarchyInspectorSectionViewModelProtocol {
        struct Details: HierarchyInspectorReferenceSummaryCellViewModelProtocol {
            let title: String
            var isEnabled: Bool
            let subtitle: String
            let image: UIImage?
            let depth: Int
            let reference: ViewHierarchyReference
        }

        var searchQuery: String? {
            didSet {
                loadData()
            }
        }

        let snapshot: ViewHierarchySnapshot

        private var searchResults = [Details]()

        init(snapshot: ViewHierarchySnapshot) {
            self.snapshot = snapshot
        }

        var isEmpty: Bool { searchResults.isEmpty }

        let numberOfSections = 1

        func selectRow(at indexPath: IndexPath) -> HierarchyInspectorCommand? {
            guard (0 ..< searchResults.count).contains(indexPath.row) else {
                return nil
            }
            let reference = searchResults[indexPath.row].reference

            return .inspect(reference)
        }

        func isRowEnabled(at indexPath: IndexPath) -> Bool {
            searchResults[indexPath.row].isEnabled
        }

        func numberOfRows(in section: Int) -> Int {
            searchResults.count
        }

        func titleForHeader(in section: Int) -> String? {
            Texts.allResults(count: searchResults.count, in: snapshot.rootReference.elementName)
        }

        func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
            .element(searchResults[indexPath.row])
        }

        func loadData() {
            guard let searchQuery = searchQuery else {
                searchResults = []
                return
            }

            let matchingReferences: [ViewHierarchyReference] = {
                let inspectableReferences = snapshot.inspectableReferences

                guard searchQuery != Inspector.configuration.showAllViewSearchQuery else {
                    return inspectableReferences
                }

                return inspectableReferences.filter {
                    ($0.displayName + $0.className).localizedCaseInsensitiveContains(searchQuery)
                }
            }()

            searchResults = matchingReferences.map { element -> Details in
                Details(
                    title: element.displayName,
                    isEnabled: true,
                    subtitle: element.elementDescription,
                    image: snapshot.elementLibraries.icon(for: element.rootView),
                    depth: element.depth,
                    reference: element
                )
            }
        }
    }
}
