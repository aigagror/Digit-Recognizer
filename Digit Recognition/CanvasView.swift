//
//  CanvasView.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let pos = touch.location(in: self)
            
            currBezierPathCoors.append(pos)
            
            
            setNeedsDisplay()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let pos = touch.location(in: self)
            
            currBezierPathCoors.append(pos)
            
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        previousBeziers.append(currBezierPathCoors)
        currBezierPathCoors = [CGPoint]()
    }

    
    
    var currBezierPathCoors = [CGPoint]()
    
    var previousBeziers = [[CGPoint]]()
    

    
    // stroke thickness
    let strokeThickness: CGFloat = 10
    
    var needsReset: Bool = false
    
    
    func getIntensities() -> Void {
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        let context = UIGraphicsGetCurrentContext()!

        
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        let cgImage = image.cgImage!
        
        let pixels = pixelValues(fromCGImage: cgImage).pixelValues!
        
        let width = cgImage.width
        let height = cgImage.height
        
        // scale it down to a mxm matrix
        
        
        
        for i in 0..<height {
            for j in 0..<width {
                
                print(pixels[i*width + j], separator: "", terminator: "\t")
                
            }
            print("")
        }
        
    }
    
    

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        if needsReset {
            
            previousBeziers.removeAll()
            currBezierPathCoors.removeAll()
            
            UIColor.clear.setFill()
            
            UIBezierPath(rect: rect).fill()
            
            needsReset = false
            
            return
        }
        
        makeBezierPath(bezierPathCoors: currBezierPathCoors)
        
        for bezierPathCoors in previousBeziers {
            makeBezierPath(bezierPathCoors: bezierPathCoors)
        }
    }
    
    private func makeBezierPath(bezierPathCoors: [CGPoint]) {
        let marker = UIBezierPath()
        marker.lineWidth = strokeThickness
        marker.lineCapStyle = .round
        marker.lineJoinStyle = .round
        
        if bezierPathCoors.count == 0 {
            return
        } else if bezierPathCoors.count == 1 {
            
            let point = bezierPathCoors.first!
            
            let square = CGRect(origin: point, size: CGSize(width: strokeThickness, height: strokeThickness))
            
            UIBezierPath(ovalIn: square).fill()
            
        } else {
            
            let numPoints = bezierPathCoors.count
            
            for i in 0 ..< (numPoints - 1) {
                let currPoint = bezierPathCoors[i]
                let target = bezierPathCoors[i+1]

                marker.move(to: currPoint)
                
                marker.addLine(to: target)
            }
            
            marker.stroke()
            
            
        }
    }
    
    private func distance(start: CGPoint, end: CGPoint) -> CGFloat {
        return sqrt( pow(end.x - start.x, 2.0) + pow(end.y - start.y, 2.0) )
    }
    
    private func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int) {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow / 4
            let totalBytes = height * bytesPerRow
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        
        return (pixelValues, width, height)
    }
    
    
    func reset() -> Void {

        needsReset = true
        
        setNeedsDisplay()
    }
}
