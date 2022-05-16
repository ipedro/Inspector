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

extension ElementInspectorViewCode {
    struct Content {
        enum `Type`: Hashable, Swift.CaseIterable {
            case panelView, scrollView, backgroundView
        }

        let view: UIView

        let type: `Type`

        private init(type: Type, view: UIView) {
            self.type = type
            self.view = view
        }

        static func panelView(_ panelView: UIView) -> Content {
            .init(type: .panelView, view: panelView)
        }

        static func scrollView(_ scrollView: UIView) -> Content {
            .init(type: .scrollView, view: scrollView)
        }

        static func empty(withMessage message: String) -> Content {
            let label = UILabel()
            label.text = message
            label.font = .preferredFont(forTextStyle: .body)
            label.directionalLayoutMargins = Inspector.sharedInstance.appearance.elementInspector.directionalInsets
            label.textAlignment = .center
            label.textColor = label.colorStyle.tertiaryTextColor

            return .init(type: .backgroundView, view: label)
        }

        static var loadingIndicator: Content {
            let activityIndicator = UIActivityIndicatorView()
            if #available(iOS 13.0, *) {
                activityIndicator.style = .large
            }
            else {
                activityIndicator.style = .whiteLarge
            }

            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = activityIndicator.colorStyle.secondaryTextColor
            activityIndicator.startAnimating()

            activityIndicator.alpha = 0
            activityIndicator.transform = .init(scaleX: 0, y: 0 )

            activityIndicator.animate(withDuration: .long, delay: .long) {
                activityIndicator.alpha = 1
                activityIndicator.transform = .identity
            }

            return .init(type: .backgroundView, view: activityIndicator.wrappedInside(UIView.self))
        }
    }
}
