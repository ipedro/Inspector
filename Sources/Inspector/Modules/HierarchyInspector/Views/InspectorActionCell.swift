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

protocol InspectorActionCellViewModelProtocol {
    var title: String { get }
    var icon: UIImage? { get }
    var isEnabled: Bool { get }
}

final class InspectorActionCell: InspectorBaseTableViewCell {
    var viewModel: InspectorActionCellViewModelProtocol? {
        didSet {
            textLabel?.text = viewModel?.title
            
            imageView?.image = viewModel?.icon
            
            contentView.alpha = viewModel?.isEnabled == true ? 1 : ElementInspector.appearance.disabledAlpha
            
            selectionStyle = viewModel?.isEnabled == true ? .default : .none
        }
    }
    
    override func setup() {
        super.setup()
        
        tintColor = ElementInspector.appearance.textColor
        
        textLabel?.textColor = ElementInspector.appearance.textColor
        textLabel?.font = .preferredFont(forTextStyle: .callout)
        
        if #available(iOS 13.0, *) {
            imageView?.layer.cornerCurve = .continuous
        }
        imageView?.layer.cornerRadius = 6
        imageView?.layer.masksToBounds = true
    }
}
