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
    static let visibleLayerAction: UIImage? = .moduleImage(named: "LayerAction-Show")
    static let hiddenLayerAction: UIImage? = .moduleImage(named: "LayerAction-Hide")
    static let emptyLayerAction: UIImage? = .moduleImage(named: "LayerAction-Empty")
    static let hideAllLayersAction: UIImage? = .moduleImage(named: "LayerAction-HideAll")
    static let showAllLayersAction: UIImage? = .moduleImage(named: "LayerAction-ShowAll")
    static let expandSymbol: UIImage? = .moduleImage(named: "expand")
    static let collapseSymbol: UIImage? = .moduleImage(named: "collapse")
    static let showHighlightsSymbol: UIImage? = .moduleImage(named: "showHighlights")
    static let hideHighlightsSymbol: UIImage? = .moduleImage(named: "hideHighlights")
    static let warningSymbol: UIImage? = .moduleImage(named: "exclamationmark.triangle")

    static let infoSymbol: UIImage? = IconKit.imageOfInfoCircleFill().withRenderingMode(.alwaysTemplate)
    static let elementAttributesSymbol: UIImage? = IconKit.imageOfSliderHorizontal().withRenderingMode(.alwaysTemplate)
    static let elementChildrenPanelSymbol: UIImage? = IconKit.imageOfRelationshipDiagram().withRenderingMode(.alwaysTemplate)
    static let elementSizePanelSymbol: UIImage? = IconKit.imageOfSetSquareFill().withRenderingMode(.alwaysTemplate)

    static let infoOutlineSymbol: UIImage? = .moduleImage(named: "info.circle")
    static let hiddenViewSymbol: UIImage? = .moduleImage(named: "Hidden-32_Normal")
    static let missingViewSymbol: UIImage? = .moduleImage(named: "missing-view-32_Normal")
    static let emptyViewSymbol: UIImage? = .moduleImage(named: "EmptyView-32_Normal")
}

@available(iOS 13.0, *)
extension UIImage {
    static let copySymbol: UIImage? = .init(systemName: "doc.on.doc")
    static let closeSymbol: UIImage? = .init(systemName: "xmark.circle")
    static let stopSymbol: UIImage? = .init(systemName: "hand.raised.fill")
    static let chevronDownSymbol: UIImage? = .init(systemName: "chevron.down.circle")
    static let chevronRightSymbol: UIImage? = .init(systemName: "chevron.right.circle")

}
