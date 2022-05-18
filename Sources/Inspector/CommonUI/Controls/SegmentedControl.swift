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
extension UISegmentedControl {
    static func segmentedControlStyle(items: [Any]? = nil) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentTintColor = segmentedControl.colorStyle.tintColor
        segmentedControl.setTitleTextAttributes([.foregroundColor: segmentedControl.colorStyle.secondaryTextColor], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: segmentedControl.colorStyle.selectedSegmentedControlForegroundColor], for: .selected)

        return segmentedControl
    }
}

final class SegmentedControl: BaseFormControl {
    // MARK: - Properties

    let options: [Any]

    override var isEnabled: Bool {
        didSet {
            segmentedControl.isEnabled = isEnabled
        }
    }

    var selectedIndex: Int? {
        get { segmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment ? nil : segmentedControl.selectedSegmentIndex }
        set { segmentedControl.selectedSegmentIndex = newValue ?? UISegmentedControl.noSegment }
    }

    private lazy var segmentedControl = UISegmentedControl.segmentedControlStyle(items: options).then {
        $0.addTarget(self, action: #selector(changeSegment), for: .valueChanged)
    }

    // MARK: - Init

    init(title: String?, images: [UIImage], selectedIndex: Int?) {
        options = images

        super.init(title: title)

        self.selectedIndex = selectedIndex
    }

    init(title: String?, texts: [String], selectedIndex: Int?) {
        options = texts

        super.init(title: title)

        self.selectedIndex = selectedIndex
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        axis = .vertical

        contentView.installView(segmentedControl)
    }

    @objc
    func changeSegment() {
        sendActions(for: .valueChanged)
    }
}
