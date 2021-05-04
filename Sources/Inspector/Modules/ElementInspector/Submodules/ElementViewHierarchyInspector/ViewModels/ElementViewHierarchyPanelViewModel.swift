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

protocol ElementViewHierarchyPanelViewModelProtocol: ViewHierarchyReferenceDetailViewModelProtocol & AnyObject {
    var parent: ElementViewHierarchyPanelViewModelProtocol? { get set }
    
    var reference: ViewHierarchyReference { get }
    
    var accessoryType: UITableViewCell.AccessoryType { get }
}


final class ElementViewHierarchyPanelViewModel {
    
    let identifier = UUID()
    
    weak var parent: ElementViewHierarchyPanelViewModelProtocol?
    
    private var _isCollapsed: Bool
    
    var title: String { reference.elementName }
    
    var subtitle: String { reference.elementDescription }
    
    let rootDepth: Int
    
    var thumbnailImage: UIImage?
    
    // MARK: - Properties
    
    let reference: ViewHierarchyReference
    
    init(
        reference: ViewHierarchyReference,
        parent: ElementViewHierarchyPanelViewModelProtocol? = nil,
        rootDepth: Int,
        thumbnailImage: UIImage?,
        isCollapsed: Bool
    ) {
        self.parent = parent
        self.reference = reference
        self.rootDepth = rootDepth
        self.thumbnailImage = thumbnailImage
        self._isCollapsed = isCollapsed
    }
}


// MARK: - ElementViewHierarchyPanelViewModelProtocol

extension ElementViewHierarchyPanelViewModel: ElementViewHierarchyPanelViewModelProtocol {
    
    var titleFont: UIFont {
        ElementInspector.appearance.titleFont(forRelativeDepth: relativeDepth)
    }
    
    var isHidden: Bool {
        parent?.isCollapsed == true || parent?.isHidden == true
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        .detailButton
    }
    
    var isCollapsed: Bool {
        get {
            isContainer ? _isCollapsed : true
        }
        set {
            guard isContainer else {
                return
            }
            
            _isCollapsed = newValue
        }
    }
    
    var isContainer: Bool {
        reference.isContainer
    }
    
    var relativeDepth: Int {
        reference.depth - rootDepth
    }
    
    var isChevronHidden: Bool {
        isContainer != true || accessoryType == .disclosureIndicator
    }
}

// MARK: - Hashable

extension ElementViewHierarchyPanelViewModel: Hashable {
    static func == (lhs: ElementViewHierarchyPanelViewModel, rhs: ElementViewHierarchyPanelViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
}

// MARK: - Images

private extension ElementViewHierarchyPanelViewModel {
    
    static let thumbnailImageLostConnection = IconKit.imageOfWifiExlusionMark(
        CGSize(
            width: ElementInspector.appearance.horizontalMargins * 1.5,
            height: ElementInspector.appearance.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)
    
    static let thumbnailImageIsHidden = IconKit.imageOfEyeSlashFill(
        CGSize(
            width: ElementInspector.appearance.horizontalMargins * 1.5,
            height: ElementInspector.appearance.horizontalMargins * 1.5
        )
    ).withRenderingMode(.alwaysTemplate)
    
}
