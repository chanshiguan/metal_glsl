//
//  ViewController.swift
//  metaltest2
//
//  Created by Wai on 2018/03/07.
//  Copyright © 2018年 momomoromo. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    
    @IBOutlet weak var mtkView: MTKView!
    
    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    
    private let vertexData: [Float] = [
        -1, -1, 0, 1,
         1, -1, 0, 1,
        -1,  1, 0, 1,
         1,  1, 0, 1
    ]
    let textureCoordinateData: [Float] =
        [
            0, 1,
            1, 1,
            0, 0,
            1, 0
    ]
    private var vertexBuffer: MTLBuffer!
    private var texCoordBuffer: MTLBuffer!
    private var timeBuffer: MTLBuffer?
    var time:Float = 0
    private var resolutionBuffer:MTLBuffer?
    private var renderPipeline: MTLRenderPipelineState!
    private let renderPassDescriptor = MTLRenderPassDescriptor()
    private var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setMetal()
        
        setBuffer()
        
        setPipeline()
        
        mtkView.enableSetNeedsDisplay = true
        mtkView.setNeedsDisplay()
        
        Timer.scheduledTimer(timeInterval: 1/60,
                             target: self,
                             selector: #selector(ViewController.setTime),
                             userInfo: nil,
                             repeats: true)
    }
    
    private func setMetal(){
        mtkView.device = device
        mtkView.delegate = self
        commandQueue = device.makeCommandQueue()
    }
    
    private func setBuffer(){
        let vertexSize = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexSize, options: [])
        let texsize = textureCoordinateData.count * MemoryLayout<Float>.size
        texCoordBuffer = device.makeBuffer(bytes: textureCoordinateData, length: texsize, options: [])
        
        let screenSize = UIScreen.main.nativeBounds.size
        let resolutionData = [Float(screenSize.width), Float(screenSize.height)]
        let resolutionSize = resolutionData.count * MemoryLayout<Float>.size
        resolutionBuffer = device.makeBuffer(bytes: resolutionData, length: resolutionSize, options: [])
        
        timeBuffer = device.makeBuffer(bytes: &time, length: MemoryLayout<Float>.size)
    }
    
    @objc private func setTime(){
        time = time + (1/60)
        timeBuffer = device.makeBuffer(bytes: &time, length: MemoryLayout<Float>.size)
        mtkView.setNeedsDisplay()
    }
    
    private func setPipeline(){
        guard let library = device.makeDefaultLibrary() else {fatalError()}
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipeline = try? device.makeRenderPipelineState(descriptor: descriptor)
        renderPipelineDescriptor = descriptor
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {return}
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {fatalError()}
        
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
        
        guard let renderPipeline = renderPipeline else {fatalError()}
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(texCoordBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(timeBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(resolutionBuffer, offset: 0, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

