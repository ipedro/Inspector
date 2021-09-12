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

extension ViewHierarchyLayersCoordinator: LayerCommandProtocol {
    func availableLayerCommands(for snapshot: ViewHierarchySnapshot) -> CommandsGroup {
        let layerToggleInputRange = Inspector.configuration.keyCommands.layerToggleInputRange
        
        let maxCount = layerToggleInputRange.upperBound - layerToggleInputRange.lowerBound
        
        let commands = snapshot.availableLayers.enumerated().map { index, layer in
            command(for: layer, at: layerToggleInputRange.lowerBound + index, isEmpty: snapshot.populatedLayers.contains(layer) == false)
        }
        
        return CommandsGroup(
            title: Texts.highlightLayers,
            commands: Array(commands.prefix(maxCount))
        )
    }
    
    func command(for layer: ViewHierarchyLayer, at index: Int, isEmpty: Bool) -> Command {
        guard isEmpty == false else {
            return .emptyLayer(layer.emptyActionTitle)
        }
        
        switch isShowingLayer(layer) {
        case true:
            return .showLayer(layer.title, at: index) { [weak self] in
                self?.removeLayer(layer)
            }
            
        case false:
            return .hideLayer(layer.title, at: index) { [weak self] in
                self?.installLayer(layer)
            }
        }
    }
    
    func toggleAllLayersCommands(for snapshot: ViewHierarchySnapshot) -> CommandsGroup {
        CommandsGroup(
            title: nil,
            commands: {
                var array = [Command]()
                
                if activeLayers.count > .zero {
                    array.append(
                        .hideVisibleLayers { [weak self] in self?.removeAllLayers() }
                    )
                }
                
                if activeLayers.count < populatedLayers.count {
                    array.append(
                        .showAllLayers { [weak self] in self?.installAllLayers() }
                    )
                }
                
                return array
            }()
        )
    }
}
