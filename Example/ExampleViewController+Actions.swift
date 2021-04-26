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
import HierarchyInspector

extension ExampleViewController {

    @IBAction func changeDatePickerStyle(_ sender: UISegmentedControl) {
        guard let datePickerStyle = UIDatePickerStyle(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        
        if #available(iOS 14.0, *) {
            if
                datePicker.datePickerMode == .countDownTimer,
                datePickerStyle == .inline || datePickerStyle == .compact
            {
                datePicker.datePickerMode = .dateAndTime
            }
        }
        
        datePicker.preferredDatePickerStyle = datePickerStyle
        
    }
    
    @IBAction func openInspector(_ sender: Any) {
        hierarchyInspectorManager?.present(animated: true)
    }
    
    @IBAction func rotateActivityIndicator(_ sender: UISlider) {
        let angle = (sender.value - 1) * .pi
        
        activityIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
    }
    
    @IBAction func toggleTextField(_ sender: UISwitch) {
        textField.isEnabled = sender.isOn
    }
    
    @objc
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ExampleViewController: UIScrollViewDelegate {
    var inspectButtonFrame: CGRect {
        inspectButton.convert(inspectButton.bounds, to: scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var inspectBarButtonAlpha: CGFloat {
            let scrollRange = inspectButtonFrame.minY ... inspectButtonFrame.maxY
            
            guard scrollView.contentOffset.y >= scrollRange.lowerBound else {
                return 0
            }
            
            guard scrollView.contentOffset.y <= scrollRange.upperBound else {
                return 1
            }
            
            let delta = (scrollView.contentOffset.y - scrollRange.lowerBound) / (scrollRange.upperBound - scrollRange.lowerBound)
            let normalizedDelta = min(1, max(0, delta))
            let alpha = pow(normalizedDelta, 4)
            
            print("scroll delta: \(delta)\t|\t normalized delta: \(normalizedDelta)\t|\t alpha: \(alpha)")
            
            return alpha
        }
        
        inspectBarButton.alpha = inspectBarButtonAlpha
    }
}
