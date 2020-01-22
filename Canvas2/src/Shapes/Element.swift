//
//  Element.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/19/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** An element is a manager for a group of quads on a layer of the canvas. */
public struct Element {
    
    // MARK: Variables
    
    internal var brush: Brush
    internal var quads: [Quad]
    
    internal var nextQuad: Quad?
    internal var lastQuad: Quad?
    
    internal var canvas: Canvas
    
    
    
    // MARK: Initialization
    
    init(quads: [Quad], canvas: Canvas, brush: Brush? = nil) {
        self.quads = quads
        self.canvas = canvas
        self.brush = brush ?? canvas.currentBrush
        
        if quads.count > 0 {
            self.nextQuad = quads[0]
        }
    }
    
    public func copy() -> Element {
        let e = Element(quads: self.quads, canvas: self.canvas, brush: self.brush)
        return e
    }
    
    
    
    // MARK: Functions
    
    /** Starts a new path using this element. */
    internal mutating func startPath(quad: Quad) {
        self.brush = canvas.currentBrush
        self.quads = [quad]
        self.nextQuad = self.quads[0]
    }
    
    /** Finishes this element so that no more quads can be added to it without starting an
     entirely new element (i.e. lifting the stylus and drawing a new curve). */
    internal mutating func closePath() {
        nextQuad = nil
        lastQuad = nil
        quads = []
    }
    
    /** Ends the last quad that exists on this element. */
    internal mutating func endPencil(at point: CGPoint) {
        guard var next = nextQuad else { return }
        next.endForce = canvas.forceEnabled ? canvas.force : 1.0
        
        // Call the quad's end method to set the vertices.
        if let last = lastQuad { next.end(at: point, brush: self.brush, prevA: last.c, prevB: last.d) }
        else { next.end(at: point, brush: self.brush) }
        
        // Finally, add the next quad onto this element.
        quads.append(next)
        
        // Make sure to move the pointers.
        lastQuad = next
        nextQuad = Quad(start: point)
    }
    
    /** Renders the element to the screen. */
    internal mutating func render(buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        guard quads.count > 0 else { return }
//        guard let rpd = canvas.currentRenderPassDescriptor else { return }
//        guard let buffer = canvas.commandQueue.makeCommandBuffer() else { return }
//        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: rpd) else { return }
        
        let vertices = quads.flatMap { $0.vertices }
        guard let vBuffer = dev.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: []) else { return }
        
        encoder.setRenderPipelineState(brush.pipeline)
        encoder.setVertexBuffer(vBuffer, offset: 0, index: 0)
        if let txr = brush.texture {
            encoder.setFragmentTexture(txr, index: 0)
        }
//        encoder.setFragmentSamplerState(sampleState, index: 0)
        let count = vBuffer.length / MemoryLayout<Vertex>.stride
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
//        encoder.endEncoding()
        print("Encoded single element")
//        for quad in quads {
//            let vertices = quad.vertices
//            guard vertices.count > 0 else {
//                print("No vertices in this quad")
//                continue
//            }
//            guard let vBuffer = dev.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: []) else {
////                encoder.endEncoding()
//                return
//            }
//
//            encoder.setRenderPipelineState(brush.pipeline)
//            encoder.setVertexBuffer(vBuffer, offset: 0, index: 0)
//            if let txr = brush.texture {
//                encoder.setFragmentTexture(txr, index: 0)
//            }
//            let count = vBuffer.length / MemoryLayout<Vertex>.stride
//            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
//        }
//        encoder.endEncoding()
//        print("Encoded single element")
    }
    
    
}