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

import Inspector
import MapKit
import UIKit
@_implementationOnly import UIKitOptions

final class PlaygroundViewController: UIViewController {
    // MARK: - Components

    @IBOutlet var activityIndicator: UIActivityIndicatorView! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleActivityIndicator))

            activityIndicator.addGestureRecognizer(gestureRecognizer)
            activityIndicator.isUserInteractionEnabled = true
        }
    }

    @objc func toggleActivityIndicator() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
        else {
            activityIndicator.startAnimating()
        }
    }

    @IBOutlet var inspectBarButton: CustomButton!

    @IBOutlet var datePickerSegmentedControl: UISegmentedControl!

    @IBOutlet var loadingView: UIView!

    @IBOutlet var datePicker: UIDatePicker!

    @IBOutlet var textField: UITextField! {
        didSet {
            toggleTextField(self.switch)
        }
    }

    @IBOutlet var longTextLabel: UILabel!

    @IBOutlet var textStackView: UIStackView!

    @IBOutlet var switchTextField: UITextField!

    @IBOutlet var `switch`: UISwitch!

    @IBOutlet var mapView: MKMapView!

    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var containerStackView: UIStackView! {
        didSet {
            containerStackView.isLayoutMarginsRelativeArrangement = true
            containerStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: 30,
                leading: 30,
                bottom: 30,
                trailing: 30
            )
        }
    }

    private var hasAppeared = false

    // MARK: - Life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard hasAppeared == false else { return }

        if #available(iOS 13.4, *) {
            setupSegmentedControl()
        }
        else {
            datePickerSegmentedControl.removeSegment(at: 1, animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        inspectAll()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopInspectingAll()
    }

    func setupSegmentedControl() {
        datePickerSegmentedControl.removeAllSegments()

        UIDatePickerStyle.allCases.forEach { style in
            datePickerSegmentedControl.insertSegment(
                withTitle: style.description,
                at: datePickerSegmentedControl.numberOfSegments,
                animated: false
            )
        }

        datePickerSegmentedControl.selectedSegmentIndex = 0
        datePicker.preferredDatePickerStyle = .automatic
    }

    // MARK: - Interface Actions

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

    @IBAction func rotateActivityIndicator(_ sender: UISlider) {
        let angle = (sender.value - 1) * .pi

        activityIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
    }

    @IBAction func toggleTextField(_ sender: UISwitch) {
        UIView.animate {
            self.textField.isEnabled = sender.isOn
            self.textField.alpha = sender.isOn ? 1 : 0.25
        }
    }

    @IBAction func openInspector(_ sender: Any) {
        presentInspector(animated: true)
    }
}
