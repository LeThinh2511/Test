//
//  ShadingView.swift
//  Test
//
//  Created by Techchain on 6/19/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class ShadingView: UIView {
    
    override func draw(_ rect: CGRect) {
        // Draw the gradient background
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create the shading function
        let function = createFunction(colorSpace: colorSpace)
        
        // Create the shading object
        var shading: CGShading? = nil
        if let function = function {
            shading = CGShading(axialSpace: colorSpace, start: CGPoint(x: 0, y: rect.size.height / 2), end: CGPoint(x: rect.size.width, y: rect.size.height / 2), function: function, extendStart: true, extendEnd: true)
        }
        
        // Draw the shading
        if let shading = shading {
            context.drawShading(shading)
        }
    }
    
    func createFunction(colorSpace: CGColorSpace) -> CGFunction? {
        struct ShadingInfo {
            let components: Int
        }
        
        final class Context {
            let info: ShadingInfo
            init(_ info: ShadingInfo) { self.info = info }
        }
        
        var inputRange: [CGFloat] = [0, 1]
        var outputRange: [CGFloat] = [0, 1, 0, 1, 0, 1, 0, 1]
        let numOfComponents = colorSpace.numberOfComponents + 1
        let shadingInfo = ShadingInfo(components: numOfComponents)
        
        var callbacks = CGFunctionCallbacks(version: 0, evaluate: { (info, inData, outData) in
            guard let info = info else { return }
            let shadingInfo = Unmanaged<Context>.fromOpaque(info).takeUnretainedValue().info
            
            let componentsCount = shadingInfo.components
            let position = inData[0]
            let blueComponents: [CGFloat] = [0, 0, 1]
            let greenComponents: [CGFloat] = [0, 1, 0]
            for i in 0..<componentsCount - 1 {
                let random = CGFloat.random(in: 0..<1)
                outData[i] = random
            }
            outData[componentsCount - 1] = 1
        }, releaseInfo: { info in
            guard let info = info else { return }
            Unmanaged<Context>.fromOpaque(info).release()
        })
        
        let unsafeSelf = Unmanaged.passRetained(Context(shadingInfo)).toOpaque()

        let function = CGFunction(info: unsafeSelf, domainDimension: 1, domain: &inputRange, rangeDimension: numOfComponents, range: &outputRange, callbacks: &callbacks)
        return function
    }
}
