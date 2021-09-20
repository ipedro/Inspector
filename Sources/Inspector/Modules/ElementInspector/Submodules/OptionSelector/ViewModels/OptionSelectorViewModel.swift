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

protocol OptionSelectorViewModelProtocol {
    var numberOfComponents: Int { get }

    var title: String? { get }

    func numberOfRows(in component: Int) -> Int

    func title(for row: Int, in component: Int) -> String?

    var selectedRow: (row: Int, component: Int)? { get }
}

final class OptionSelectorViewModel {
    let options: [Swift.CustomStringConvertible]

    var selectedIndex: Int?

    let title: String?

    init(title: String?, options: [Swift.CustomStringConvertible], selectedIndex: Int?) {
        self.title = title
        self.options = options
        self.selectedIndex = selectedIndex
    }
}

extension OptionSelectorViewModel: OptionSelectorViewModelProtocol {
    var numberOfComponents: Int {
        1
    }

    func numberOfRows(in component: Int) -> Int {
        switch component {
        case .zero:
            return options.count

        default:
            return .zero
        }
    }

    func title(for row: Int, in component: Int) -> String? {
        switch component {
        case .zero:
            return options[row].description

        default:
            return nil
        }
    }

    var selectedRow: (row: Int, component: Int)? {
        guard let selectedIndex = selectedIndex else {
            return nil
        }

        return (row: selectedIndex, component: .zero)
    }
}
