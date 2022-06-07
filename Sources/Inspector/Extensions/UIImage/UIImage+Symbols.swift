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

// MARK: - Element Inspector Panels

extension UIImage {
    static let elementIdentityPanel: UIImage = .moduleImage(named: "identityPanel")!
    static let elementAttributesPanel: UIImage = IconKit.imageOfSliderHorizontal().withRenderingMode(.alwaysTemplate)
    static let elementChildrenPanel: UIImage = IconKit.imageOfRelationshipDiagram().withRenderingMode(.alwaysTemplate)
    static let elementSizePanel: UIImage = IconKit.imageOfSetSquareFill().withRenderingMode(.alwaysTemplate)
}

extension UIImage {
    static let collapseMirroredSymbol: UIImage = .moduleImage(named: "collapse-mirrored")!
    static let collapseSymbol: UIImage = .moduleImage(named: "collapse")!
    static let emptyViewSymbol: UIImage = .moduleImage(named: "EmptyView-32_Normal")!
    static let expandSymbol: UIImage = .moduleImage(named: "expand")!
    static let hiddenViewSymbol: UIImage = .moduleImage(named: "Hidden-32_Normal")!
    static let hideHighlightsSymbol: UIImage = .moduleImage(named: "hideHighlights")!
    static let infoOutlineSymbol: UIImage = .moduleImage(named: "info.circle")!
    static let missingSymbol: UIImage = .moduleImage(named: "missing-view-32_Normal")!
    static let showHighlightsSymbol: UIImage = .moduleImage(named: "showHighlights")!
    static let warningSymbol: UIImage = .moduleImage(named: "exclamationmark.triangle")!
    static let infoSymbol: UIImage = IconKit.imageOfInfoCircleFill().withRenderingMode(.alwaysTemplate)
}

extension UIImage {
    static let chevronDownSymbol: UIImage = .light(systemName: "chevron.down.circle")!
    static let chevronRightSymbol: UIImage = .light(systemName: "chevron.right.circle")!
    static let closeSymbol: UIImage = .light(systemName: "xmark.circle")!
    static let copySymbol: UIImage = .light(systemName: "doc.on.doc")!
    static let stopSymbol: UIImage = .light(systemName: "hand.raised.fill")!
    static let emptyLayerAction: UIImage = .light(systemName: "questionmark.circle")!
    static let hideAllLayersAction: UIImage = .light(systemName: "square.stack.3d.up.slash.fill")!
    static let showAllLayersAction: UIImage = .light(systemName: "square.stack.3d.up.fill")!
    static let layerAction: UIImage = .light(systemName: "square.3.stack.3d.middle.filled")!
    // static let visibleLayerAction: UIImage =  .light(systemName: "square.3.stack.3d")!
}
