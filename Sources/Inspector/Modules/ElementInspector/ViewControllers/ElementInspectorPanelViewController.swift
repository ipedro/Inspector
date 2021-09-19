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

typealias ElementInspectorPanelViewController = ElementInspectorBasePanelViewController & ElementInspectorPanelViewControllerProtocol

class ElementInspectorBasePanelViewController: UIViewController {
    // MARK: - Layout

    var hasScrollView: Bool {
        view.subviews.contains { $0 is UIScrollView }
    }
    
    private var needsLayout = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard needsLayout else { return }
        
        needsLayout = false
        
        updatePreferredContentSize()
    }
    
    @objc
    func updatePreferredContentSize() {
        guard
            let self = self as? ElementInspectorPanelViewController,
            modalPresentationStyle == .popover
        else {
            return
        }
        
        preferredContentSize = self.calculatePreferredContentSize()
    }

    func calculatePreferredContentSize() -> CGSize {
        if isViewLoaded {
            return view.systemLayoutSizeFitting(
                ElementInspector.appearance.panelPreferredCompressedSize,
                withHorizontalFittingPriority: .defaultHigh,
                verticalFittingPriority: .fittingSizeLevel
            )
        }
        else {
            return .zero
        }
    }
}
