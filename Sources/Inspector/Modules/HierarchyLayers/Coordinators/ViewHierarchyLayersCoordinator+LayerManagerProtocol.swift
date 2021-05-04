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

// MARK: - LayerManagerProtocol

extension ViewHierarchyLayersCoordinator: LayerManagerProtocol {
    
    // MARK: - Install
    
    func installLayer(_ layer: ViewHierarchyLayer) {
        guard let viewHierarchySnapshot = dataSource?.viewHierarchySnapshot else {
            return
        }
        
        asyncOperation(name: layer.title) {
            self.create(layer: layer, for: viewHierarchySnapshot)
        }
    }
    
    func installAllLayers() {
        guard let viewHierarchySnapshot = dataSource?.viewHierarchySnapshot else {
            return
        }
        
        asyncOperation(name: Texts.showAllLayers) {
            for layer in self.populatedLayers where layer.allowsSystemViews == false {
                self.create(layer: layer, for: viewHierarchySnapshot)
            }
        }
    }
    
    // MARK: - Remove
    
    func removeAllLayers() {
        guard isShowingLayers else {
            return
        }
        
        asyncOperation(name: Texts.hideVisibleLayers) {
            self.destroyAllLayers()
        }
    }

    func removeLayer(_ layer: ViewHierarchyLayer) {
        guard isShowingLayers else {
            return
        }
        
        asyncOperation(name: layer.title) {
            self.destroy(layer: layer)
        }
    }
    
}
