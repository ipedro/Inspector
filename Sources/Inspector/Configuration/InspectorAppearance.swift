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

struct InspectorAppearance: Hashable {
    // MARK: - Wireframe Style

    var regularIconSize = CGSize(width: 20, height: 20)

    var actionIconSize = CGSize(width: 24, height: 24)

    var elementIconSize: CGSize {
        CGSize(
            width: elementInspector.verticalMargins * 3,
            height: elementInspector.verticalMargins * 3
        )
    }

    var elementInspector = ElementInspectorAppearance()

    var highlightLayerBorderWidth: CGFloat = 2 / UIScreen.main.scale

    var wireframeLayerBorderWidth: CGFloat = 1 / UIScreen.main.scale

    // MARK: - Empty Layer Style

    var emptyLayerBorderWidth: CGFloat = 0
}
