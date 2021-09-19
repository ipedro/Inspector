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

public protocol InspectorElementFormSectionViewDelegate: AnyObject {
    func inspectorElementFormSectionView(_ section: InspectorElementFormSectionView,
                                         changedFrom oldState: InspectorElementFormSectionState?,
                                         to newState: InspectorElementFormSectionState)
}

public protocol InspectorElementFormSectionView: UIView {
    var delegate: InspectorElementFormSectionViewDelegate? { get set }

    /// Optional section title.
    var title: String? { get set }

    /// Optional section subtitle.
    var subtitle: String?  { get set }

    /// Defines the section separator appearance.
    var separatorStyle: InspectorElementFormSectionSeparatorStyle { get set }

    /// Optional view that is usually shown next to the section title.
    var accessoryView: UIView?  { get set }

    /// The current state of the section.
    var state: InspectorElementFormSectionState { get set }

    /// When this method is called is your view's responsibility to add the given form views to it's hiearchy.
    func addFormViews(_ formViews: [UIView])

    /// Creates a section view.
    static func createSectionView() -> InspectorElementFormSectionView
}
