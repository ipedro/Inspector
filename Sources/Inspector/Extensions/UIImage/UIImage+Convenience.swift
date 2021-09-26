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

extension UIImage {
    static let internalViewIcon: UIImage? = .moduleImage(named: "InternalView-32_Normal")
    static let visibleLayerAction: UIImage? = .moduleImage(named: "LayerAction-Show")
    static let hiddenLayerAction: UIImage? = .moduleImage(named: "LayerAction-Hide")
    static let emptyLayerAction: UIImage? = .moduleImage(named: "LayerAction-Empty")
    static let hideAllLayersAction: UIImage? = .moduleImage(named: "LayerAction-HideAll")
    static let showAllLayersAction: UIImage? = .moduleImage(named: "LayerAction-ShowAll")
}

@available(iOS 13.0, *)
extension UIImage {
    static let copySymbol: UIImage? = .init(systemName: "doc.on.doc")
    static let closeSymbol: UIImage? = .init(systemName: "xmark.circle")
    static let stopSymbol: UIImage? = .init(systemName: "hand.raised.fill")
    static let chevronDownSymbol: UIImage? = .init(systemName: "chevron.down.circle")
    static let chevronRightSymbol: UIImage? = .init(systemName: "chevron.right.circle")
}
