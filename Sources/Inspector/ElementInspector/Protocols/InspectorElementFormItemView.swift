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

public protocol InspectorElementFormItemViewDelegate: AnyObject {
    func inspectorElementFormItemView(_ item: InspectorElementFormItemView,
                                      willChangeFrom oldState: InspectorElementFormItemState?,
                                      to newState: InspectorElementFormItemState)
}

public protocol InspectorElementFormItemView: UIView {
    var delegate: InspectorElementFormItemViewDelegate? { get set }

    /// Optional section title.
    var title: String? { get set }

    /// Optional section subtitle.
    var subtitle: String? { get set }

    /// Defines the section separator appearance.
    var separatorStyle: InspectorElementFormItemSeparatorStyle { get set }

    /// The current state of the section.
    var state: InspectorElementFormItemState { get set }

    /// When this method is called is your view's responsibility to add the given form views to it's hiearchy.
    func addFormViews(_ formViews: [UIView])

    /// Create and return a container view that conforms to the `InspectorElementFormItemView` protocol.
    static func makeItemView(with inititalState: InspectorElementFormItemState) -> InspectorElementFormItemView
}
