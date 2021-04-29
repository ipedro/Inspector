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

final class ElementViewHierarchyInspectorTableViewCodeCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var referenceDetailView = ViewHierarchyReferenceDetailView()
    
    var viewModel: ElementViewHierarchyPanelViewModelProtocol? {
        didSet {
            
            referenceDetailView.viewModel = viewModel
            
            accessoryType = viewModel?.accessoryType ?? .none
        }
    }
    
    var isEvenRow = false {
        didSet {
            switch isEvenRow {
            case true:
                backgroundColor = ElementInspector.appearance.panelBackgroundColor
                
            case false:
                backgroundColor = ElementInspector.appearance.panelHighlightBackgroundColor
            }
        }
    }
    
    func toggleCollapse(animated: Bool) {
        guard animated else {
            referenceDetailView.isCollapsed.toggle()
            return
        }
        
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak self] in
                
                self?.referenceDetailView.isCollapsed.toggle()
                
            },
            completion: nil
        )
    }
    
    private lazy var customSelectedBackgroundView = UIView(
        .backgroundColor(ElementInspector.appearance.tintColor.withAlphaComponent(0.1))
    )
    
    private func setup() {
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        isOpaque = true
        
        clipsToBounds = true
        
        selectedBackgroundView = customSelectedBackgroundView
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        contentView.isUserInteractionEnabled = false
        
        contentView.installView(referenceDetailView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
    }
    
}