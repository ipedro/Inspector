//
//  ExampleViewController+Actions.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

// MARK: - Actions

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
        presentHierarchyInspector(animated: true)
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
