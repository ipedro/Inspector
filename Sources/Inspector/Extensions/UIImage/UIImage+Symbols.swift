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
    static let elementAttributesPanel: UIImage = IconKit.imageOfSliderHorizontal().withRenderingMode(.alwaysTemplate)
    static let elementChildrenPanel: UIImage = IconKit.imageOfRelationshipDiagram().withRenderingMode(.alwaysTemplate)
    static let elementIdentityPanel: UIImage = .icon("identityPanel")!
    static let elementSizePanel: UIImage = IconKit.imageOfSetSquareFill().withRenderingMode(.alwaysTemplate)
}

extension UIImage {
    static let applicationIcon: UIImage = .systemIcon("app.badge.fill")!
    static let collapseMirroredSymbol: UIImage = .icon("collapse-mirrored")!
    static let collapseSymbol: UIImage = .icon("collapse")!
    static let collectionViewController: UIImage = .systemIcon("square.grid.3x3")!
    static let emptyViewSymbol: UIImage = .icon("EmptyView-32_Normal")!
    static let expandSymbol: UIImage = .icon("expand")!
    static let hiddenViewSymbol: UIImage = .icon("Hidden-32_Normal")!
    static let infoOutlineSymbol: UIImage = .icon("info.circle")!
    static let infoSymbol: UIImage = IconKit.imageOfInfoCircleFill().withRenderingMode(.alwaysTemplate)
    static let missingSymbol: UIImage = .icon("missing-view-32_Normal")!
    static let navigationController: UIImage = .systemIcon("chevron.left.square")!
    static let nsObject: UIImage = .systemIcon("shippingbox", weight: .regular)!
    static let warningSymbol: UIImage = .icon("exclamationmark.triangle")!
}

extension UIImage {
    static let chevronDownSymbol: UIImage = .systemIcon("chevron.down.circle", weight: .regular)!
    static let chevronRightSymbol: UIImage = .systemIcon("chevron.right.circle", weight: .regular)!
    static let closeSymbol: UIImage = .systemIcon("xmark.circle", weight: .regular)!
    static let copySymbol: UIImage = .systemIcon("doc.on.doc", weight: .regular)!
    static let emptyLayerAction: UIImage = .systemIcon("questionmark.diamond", weight: .regular)!
    static let layerAction: UIImage = .systemIcon("square.stack.3d.up.fill", weight: .regular)!
    static let layerActionHideAll: UIImage = .systemIcon("square.stack.3d.up.slash.fill", weight: .regular)!
    static let layerActionShowAll: UIImage = .systemIcon("square.stack.3d.up.badge.a.fill", weight: .regular, prefersHierarchicalColor: false)!
    static let wireframeAction: UIImage = .systemIcon("square.stack.3d.up", weight: .regular)!
}
