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
        
        if let delegate = delegate {
            delegate.userDidFinishWriting()
        }
    }

    
    // MARK: Properties
    
    var delegate: CanvasViewDelegate? = nil
    
    
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

  
    func getCroppedBitMap(dimension: Int) -> [[UInt8]]? {
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        let context = UIGraphicsGetCurrentContext()!
        
        
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        let cgImage = image.cgImage!
        
        var oldPixels = pixelValues(fromCGImage: cgImage).pixelValues!
        
        // invert the values
        for i in 0..<oldPixels.count {
            oldPixels[i] = 255 - oldPixels[i]
        }
        
        // make sure there is at least a mark
        
        var emptyCanvas = true
        for pixel in oldPixels {
            if pixel > 0 {
                emptyCanvas = false
                break
            }
        }
        if emptyCanvas {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // crop the pixels so that the marks fill the entire square
        
        // get rowIndex of beginning and end of marks
        var startRowMarkIndex = -1
        var endRowMarkIndex = -1
        
        for j in 0..<width {
            var hitMarkFromLeft = false
            for i in 0..<height {
                let pixel = oldPixels[i*width + j]
                
                if pixel > 0 {
                    hitMarkFromLeft = true
                    break
                }
            }
            
            if hitMarkFromLeft {
                startRowMarkIndex = j
                break
            }
        }
        
        for j in (0..<width).reversed() {
            var hitMarkFromRight = false
            for i in 0..<height {
                let pixel = oldPixels[i*width + j]
                
                if pixel > 0 {
                    hitMarkFromRight = true
                    break
                }
            }
            
            if hitMarkFromRight {
                endRowMarkIndex = j
                break
            }
        }
        
        // get columnIndex of beginning and end of marks
        var startColumnMarkIndex = -1
        var endColumnMarkIndex = -1
        
        for i in 0..<height {
            var hitMarkFromTop = false
            for j in 0..<width {
                let pixel = oldPixels[i*width + j]
                
                if pixel > 0 {
                    hitMarkFromTop = true
                    break
                }
            }
            
            if hitMarkFromTop {
                startColumnMarkIndex = i
                break
            }
        }
        
        for i in (0..<height).reversed() {
            var hitMarkFromBottom = false
            for j in 0..<width {
                let pixel = oldPixels[i*width + j]
                
                if pixel > 0 {
                    hitMarkFromBottom = true
                    break
                }
            }
            
            if hitMarkFromBottom {
                endColumnMarkIndex = i
                break
            }
        }
        
        guard startRowMarkIndex >= 0 && startColumnMarkIndex >= 0 && endRowMarkIndex >= 0 && endColumnMarkIndex >= 0 else {
            fatalError("Failed to crop")
        }
        guard endRowMarkIndex > startRowMarkIndex && endColumnMarkIndex > startColumnMarkIndex else {
            fatalError("Failed to crop")
        }
        
        let croppedDimension = max((endColumnMarkIndex - startColumnMarkIndex + 1), (endRowMarkIndex - startRowMarkIndex + 1))
        
        // too small
        if croppedDimension < dimension {
            return nil
        }
        
        var croppedPixels = [UInt8](repeatElement(0, count: croppedDimension*croppedDimension))
        for x in startRowMarkIndex...endRowMarkIndex {
            for y in startColumnMarkIndex...endColumnMarkIndex {
                
                let i = x - startRowMarkIndex
                let j = y - startColumnMarkIndex
                
                croppedPixels[j * croppedDimension + i] = oldPixels[y * width + x]
            }
        }
        
        
        
        // scale it down to a dimension x dimension matrix
        var newPixels = [[UInt8]](repeating: [UInt8](repeating: 0, count: dimension), count: dimension)
        
        if dimension <= croppedDimension && dimension <= croppedDimension {
            
            let widthScaleFactor = Double(croppedDimension) / Double(dimension)
            let heightScaleFactor = Double(croppedDimension) / Double(dimension)
            
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
                            
                            sum += Int(croppedPixels[y*croppedDimension + x])
                            
                        }
                    }
                    
                    let numberOfMappedPixels = Double(endX - startX) * Double(endY - startY)
                    
                    newPixels[i][j] = UInt8(Double(sum) / numberOfMappedPixels)
                }
            }
        } else {
            fatalError()
        }
        
//        // print bitmap
//        for row in newPixels {
//            for index in row {
//                print(index, separator: "", terminator: "\t")
//            }
//            print("\n")
//        }
        
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
