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

protocol ViewHierarchyElementReference: ViewHierarchyElementRepresentable & AnyObject {
    var underlyingView: UIView? { get }

    func hasChanges(inRelationTo identifier: UUID) -> Bool

    var latestSnapshotIdentifier: UUID { get }

    var iconImage: UIImage? { get }

    var parent: ViewHierarchyElementReference? { get set }

    var depth: Int { get set }

    var children: [ViewHierarchyElementReference] { get set }
}

extension ViewHierarchyElementReference {
    var isContainer: Bool { !children.isEmpty }

    var allChildren: [ViewHierarchyElementReference] {
        children.reversed().flatMap { [$0] + $0.allChildren }
    }

    var allParents: [ViewHierarchyElementReference] {
        var array = [ViewHierarchyElementReference]()

        if let parent = parent {
            array.append(parent)
            array.append(contentsOf: parent.allParents)
        }

        return array
    }

    var summaryInfo: ViewHierarchyElementSummary {
        ViewHierarchyElementSummary(
            iconImage: iconImage,
            isContainer: isContainer,
            subtitle: elementDescription,
            title: elementName
        )
    }

    // MARK: - Layer Views Convenience Methods

    var isShowingLayerWireframeView: Bool {
        underlyingView?.allSubviews.contains { $0 is WireframeView } ?? false
    }

    var isHostingAnyLayerHighlightView: Bool {
        underlyingView?.allSubviews.contains { $0 is HighlightView } ?? false
    }

    var containsVisibleHighlightViews: Bool {
        underlyingView?.allSubviews.contains { ($0 as? HighlightView)?.isHidden == false } ?? false
    }

    var highlightView: HighlightView? {
        underlyingView?._highlightView
    }
}
