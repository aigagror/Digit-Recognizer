//
//  CanvasView.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    
    // MARK: Touch Events
    
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

    
    // MARK: Properties
    var currBezierPathCoors = [CGPoint]()
    
    var previousBeziers = [[CGPoint]]()
    

    let strokeThickness: CGFloat = 30
    
    var needsReset: Bool = false
    
    
    // MARK: Drawing

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
  
    func getIntensities(dimension: Int) -> [[UInt8]] {
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        let context = UIGraphicsGetCurrentContext()!
        
        
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        let cgImage = image.cgImage!
        
        let oldPixels = pixelValues(fromCGImage: cgImage).pixelValues!
        
        let width = cgImage.width
        let height = cgImage.height
        
        
        // scale it down to a dimension x dimension matrix
        var newPixels = [[UInt8]](repeating: [UInt8](repeating: 0, count: dimension), count: dimension)
        
        if dimension <= width && dimension <= height {
            
            let widthScaleFactor = Double(width) / Double(dimension)
            let heightScaleFactor = Double(height) / Double(dimension)
            
            for i in 0..<dimension {
                for j in 0..<dimension {
                    
                    // get the set of pixels from oldPixels that map to new pixels
                    
                    let startX = Int(Double(j) * widthScaleFactor)
                    let startY = Int(Double(i) * heightScaleFactor)
                    
                    let endX = Int(Double(j+1) * widthScaleFactor)
                    let endY = Int(Double(i+1) * heightScaleFactor)
                    
                    var sum = 0
                    for x in startX..<endX {
                        for y in startY..<endY {
                            
                            sum += Int(oldPixels[y*width + x])
                            
                        }
                    }
                    
                    let numberOfMappedPixels = Double(endX - startX) * Double(endY - startY)
                    
                    newPixels[i][j] = UInt8(Double(sum) / numberOfMappedPixels)
                }
            }
        } else {
            fatalError()
        }
        
        return newPixels
    }
    
    func reset() -> Void {
        
        needsReset = true
        
        setNeedsDisplay()
    }
    
    // MARK: Private functions
    
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
    
    
    private func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int) {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = width
            let totalBytes = height * bytesPerRow
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        
        return (pixelValues, width, height)
    }
}
