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

import Foundation

extension ViewHierarchyReference {

    var constraintReferences: [NSLayoutConstraintInspectableViewModel] {
        guard let view = rootView else { return [] }

        return view.constraints.compactMap {
            NSLayoutConstraintInspectableViewModel(with: $0, in: view)
        }
        .uniqueValues()
    }

    var horizontalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        constraintReferences.filter { $0.axis == .horizontal }
    }

    var verticalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        constraintReferences.filter { $0.axis == .vertical }
    }

    var elementDescription: String {
        var strings = [String?]()
        
        var constraints: String? {
            let totalCount = constraintReferences.count

            if totalCount == .zero {
                return nil
            }
            else {
                return totalCount == 1 ? "1 Constraint" : "\(totalCount) Constraints"
            }

//            let components: [String?] = [
//                "\(totalCount == 1 ? "1 Constraint" : "\(totalCount) Constraints")",
//                "",
//                horizontal.isEmpty ? nil : "Horizontal Constraints",
//                horizontal.prefix(3).compactMap { $0.displayName }.joined(separator: "\n"),
//                horizontal.count > 3 ? "..." : nil,
//                "",
//                vertical.isEmpty ? nil : "Vertical Constraints",
//                vertical.prefix(3).compactMap { $0.displayName }.joined(separator: "\n"),
//                vertical.count > 3 ? "..." : nil
//            ]
//
//            return components
//            .compactMap { $0 }
//            .joined(separator: "\n")
        }
        
        var subviews: String? {
            guard isContainer else {
                return nil
            }
            return "\(flattenedSubviewReferences.count) children. (\(children.count) subviews)"
        }
        
        var frame: String? {
            guard let view = rootView else {
                return nil
            }
            
            return "x: \(Int(view.frame.origin.x)), y: \(Int(view.frame.origin.y)) – w: \(Int(view.frame.width)), h: \(Int(view.frame.height))"
        }
        
        var className: String? {
            guard let view = rootView else {
                return nil
            }
            
            guard let superclass = view.superclass else {
                return view.className
            }
            
            return "\(view.className) (\(String(describing: superclass)))"
        }
        
        strings.append(className)
        
        strings.append(frame)
        
        strings.append(subviews)
        
        strings.append(constraints)
        
        return strings.compactMap { $0 }.joined(separator: "\n")
    }
}
