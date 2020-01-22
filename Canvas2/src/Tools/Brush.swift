//
//  Brush.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/15/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** A customizable brush that determines how curves drawn on the canvas will look. */
public struct Brush {
    
    // MARK: Variables
    
    internal var canvas: Canvas
    
    internal var name: String
    
    internal var size: CGFloat
    
    internal var color: UIColor
    
    internal var texture: MTLTexture?
    
    internal var isEraser: Bool {
        didSet {
            // When you use an eraser, set its color to the canvas's clear color.
            if self.isEraser == true { self.color = self.canvas.canvasColor }
        }
    }
    
    internal var pipeline: MTLRenderPipelineState!
    
    
    
    
    
    // MARK: Initialization
    
    init(canvas: Canvas, name: String, size s: CGFloat, color c: UIColor = UIColor.black, isEraser: Bool = false) {
        self.canvas = canvas
        self.name = name
        self.size = s
        self.color = (isEraser == true ? canvas.canvasColor : c)
        self.texture = nil
        self.isEraser = isEraser
    }
    
    
    // MARK: Functions
    
    /** Sets the texture on this brush using a texture name that has already been added to the canvas. */
    public mutating func setTexture(name: String) {
        guard let txr = canvas.getTexture(withName: name) else { return }
        self.texture = txr
    }
    
    
    /** Sets up the pipeline for this brush. */
    internal mutating func setupPipeline() {
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        self.pipeline = buildRenderPipeline(vertProg: vertProg, fragProg: fragProg, modesOn: false, eraserSettingsOn: self.isEraser)
        print("Created brush specific pipeline for brush: \(name).")
    }
    
    /** Makes a copy of this brush. */
    func copy() -> Brush {
        var b: Brush = Brush(canvas: self.canvas, name: self.name, size: self.size, color: self.color, isEraser: self.isEraser)
        b.texture = self.texture
        b.pipeline = self.pipeline
        return b
    }
}
