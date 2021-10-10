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

@available(*, deprecated, renamed: "InspectorElementLibraryItemProtocol")
public typealias InspectorElementViewModelProtocol = InspectorElementSectionDataSource

/// An object that provides the information necessary to represent an Element Inspector section.
public protocol InspectorElementSectionDataSource: AnyObject {
    /// An optional subtitle that can be shown below the title.
    var title: String { get }
    /// An optional subtitle that can be shown below the title.
    var subtitle: String? { get }
    /// A list of properties to be displayed.
    var properties: [InspectorElementProperty] { get }
    /// To customize how your sections look provide a type that conforms to `InspectorElementFormSectionView`.
    var customClass: InspectorElementSectionView.Type? { get }
    /// Constant describing the currentstate of the section.
    var state: InspectorElementSectionState { get set }
    /// An optional property to be displayed next to the title.
    var titleAccessoryProperty: InspectorElementProperty? { get }
}

public extension InspectorElementSectionDataSource {
    var subtitle: String? { nil }
    var customClass: InspectorElementSectionView.Type? { nil }
    var titleAccessoryProperty: InspectorElementProperty? { nil }
}

extension InspectorElementSectionDataSource {
    func makeView() -> InspectorElementSectionView {
        let aClass = customClass ?? InspectorElementSectionFormView.self

        let view = aClass.makeItemView(with: state)

        return view
    }
}
