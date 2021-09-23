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

final class PlaygroundViewController: UIViewController {
    // MARK: - Stack Views

    @IBOutlet var sliderStackView: UIStackView! {
        didSet {
            sliderStackView.accessibilityIdentifier = "Slider Stack View"
        }
    }

    @IBOutlet var datePickerStackView: UIStackView! {
        didSet {
            datePickerStackView.accessibilityIdentifier = "Date Picker Stack View"
        }
    }

    @IBOutlet var contentStackView: UIStackView! {
        didSet {
            contentStackView.accessibilityIdentifier = "Content Stack View"
            contentStackView.isLayoutMarginsRelativeArrangement = true
        }
    }

    @IBOutlet var textViewStack: UIStackView! {
        didSet {
            textViewStack.accessibilityIdentifier = "Text Stack View"
        }
    }

    @IBOutlet var mapStackView: UIStackView! {
        didSet {
            mapStackView.accessibilityIdentifier = "Map Stack View"
        }
    }

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

    @IBOutlet var datePicker: UIDatePicker!

    @IBOutlet var mapView: MKMapView!

    @IBOutlet var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInset = .init(top: .zero, left: .zero, bottom: -80, right: .zero)
        }
    }

    private var hasAppeared = false

    override var keyCommands: [UIKeyCommand]? { Inspector.keyCommands }

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

        Inspector.removeAllLayers()
        Inspector.toggleAllLayers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Inspector.removeAllLayers()
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

    @IBAction func openInspector(_ sender: Any) {
        Inspector.present(animated: true)
    }
}

final class PlaygroundContainerStackView: UIStackView, NonInspectableView {
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 60,
            leading: 30,
            bottom: 30,
            trailing: 30
        )
    }
}
