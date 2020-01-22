//
//  Canvas+Layers.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

/** Extension that handles managing canvas layers. */
public extension Canvas {
    
    /** Returns whether or not the user is currently on a valid layer. */
    internal func isOnValidLayer() -> Bool {
        guard canvasLayers.count > 0 else { return false }
        guard currentLayer >= 0 && currentLayer < canvasLayers.count else { return false }
        if canvasLayers[currentLayer].isLocked == true { return false }
        return true
    }
    
    /** Adds a layer to the canvas. */
    func addLayer(at index: Int) {
        // Adding a layer does not require a rebuild of the buffer
        // because that will happen when the user draws again.
        if self.canvasLayers.count == 0 {
            self.canvasLayers.append(Layer(canvas: self))
            self.currentLayer = 0
            return
        }
        
        let newLayer = Layer(canvas: self)
        self.canvasLayers.insert(newLayer, at: index)
        rebuildBuffer()
    }
    
    
    /** Deletes a layer from the canvas. */
    func removeLayer(at index: Int) {
        guard index >= 0 && index <= self.canvasLayers.count else { return }
        
        // Remove the canvas layer.
        self.canvasLayers.remove(at: index)
        if self.currentLayer >= self.canvasLayers.count {
            self.currentLayer = self.canvasLayers.count - 1
        }
        
        // Rebuild the buffer.
        rebuildBuffer()
    }
    
    
    /** Moves the layer at the specified index to a different position on the canvas. */
    func moveLayer(from startIndex: Int, to destIndex: Int) {
        guard startIndex >= 0 && startIndex < self.canvasLayers.count else { return }
        guard destIndex >= 0 && destIndex < self.canvasLayers.count else { return }
        
        let moveLayer = canvasLayers[startIndex]
        canvasLayers.remove(at: startIndex)
        canvasLayers.insert(moveLayer, at: destIndex)
        
        rebuildBuffer()
    }
    
    
    /** Locks a particular layer so that no actions can be taken on it. */
    func lock(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        canvasLayers[currentLayer].isLocked = true
    }
    
    
    /** Unlocks a particular layer so that you can interact with it again. */
    func unlock(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        canvasLayers[currentLayer].isLocked = false
    }
    
}
