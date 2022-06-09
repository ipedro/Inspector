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

extension ViewHierarchyCoordinator: LayerCommandProtocol {
    func availableLayerCommands(for snapshot: ViewHierarchySnapshot) -> [Command] {
        let maxCount = layerToggleInputRange.upperBound - layerToggleInputRange.lowerBound

        let commands = snapshot.populatedLayers
            .enumerated()
            .compactMap { index, layer in
                command(
                    for: layer,
                    at: layerToggleInputRange.lowerBound + index + 1,
                    isEmpty: snapshot.populatedLayers.contains(layer) == false
                )
            }

        return Array(commands.prefix(maxCount))
    }

    func command(for layer: ViewHierarchyLayer, at index: Int, isEmpty: Bool) -> Command? {
        if isEmpty { return .none }

        let isSelected = isShowingLayer(layer)
        let icon: UIImage = layer == .wireframes ? .wireframeAction : .layerAction
        let title: String = {
            switch (layer, isSelected) {
            case (.wireframes, true): return Texts.enable(layer.title)
            case (.wireframes, false): return Texts.disable(layer.title)
            default: return layer.title
            }
        }()

        return Command(
            title: title,
            icon: icon,
            keyCommandOptions: Command.keyCommand(index: index),
            isSelected: isSelected
        ) { [weak self] in
            guard let self = self else { return }
            isSelected ? self.removeLayer(layer) : self.installLayer(layer)
        }
    }

    func toggleAllLayersCommands(for snapshot: ViewHierarchySnapshot) -> [Command] {
        var array = [Command]()
        if activeLayers.count < populatedLayers.count {
            array.append(
                .showAllLayers { [weak self] in
                    guard let self = self else { return }
                    self.installAllLayers()
                }
            )
        }
        if activeLayers.count > .zero {
            array.append(
                .hideVisibleLayers { [weak self] in
                    guard let self = self else { return }
                    self.removeAllLayers()
                }
            )
        }
        return array
    }
}
