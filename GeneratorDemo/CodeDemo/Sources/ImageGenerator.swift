//
//  ImageGenerator.swift//
//
//  Created by 谢恩平 on 2024/12/16.
//

import Foundation
import CoreGraphics
import AppKit  // 需要用到 NSBitmapImageRep 和 NSImage

class ImageGenerator {
    static func createImage(infoDotsDiameter: Int, model: InfoDotsModel) -> CGImage? {
        // 点位信息
        let dotsTable = model.dotsTable
        
        // 颜色
        let colorizer = RCColorizer()
        
        // 形状数据
        let shapeInfo = model.shapeInfo
        shapeInfo.infoDotsDiameter = infoDotsDiameter
        
        let infoDotsDiameter = shapeInfo.infoDotsDiameter
        let numOfPointBar = shapeInfo.numOfPointBar
        let lengthOfCRange = shapeInfo.lengthOfCRange
        let centerCircleDiameter = shapeInfo.centerCircleDiameter
        let radiusOfCenterCircle = centerCircleDiameter / 2
        let radiusOfInnerSquare = lengthOfCRange / 2

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: lengthOfCRange, height: lengthOfCRange, bitsPerComponent: 8, bytesPerRow: lengthOfCRange * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // 整体填充白色
        context.setFillColor(CGColor.white)
        context.fill(CGRect(x: 0, y: 0, width: lengthOfCRange, height: lengthOfCRange))

        // 画三个定位符号
        let positionOfLocatonSymbols = shapeInfo.positionOfLocatonSymbols
        drawLocationSymbol(centerX: positionOfLocatonSymbols.northwestCenterPos.x, centerY: positionOfLocatonSymbols.northwestCenterPos.y)
        drawLocationSymbol(centerX: positionOfLocatonSymbols.southwestCenterPos.x, centerY: positionOfLocatonSymbols.southwestCenterPos.y)
        drawLocationSymbol(centerX: positionOfLocatonSymbols.southeastCenterPos.x, centerY: positionOfLocatonSymbols.southeastCenterPos.y)
        
        // 坐标中心转换到正方形中心
        context.translateBy(x: CGFloat(radiusOfInnerSquare), y: CGFloat(radiusOfInnerSquare))

        // 画中心圆
        context.setFillColor(CGColor(red: 21/255.0, green: 21/255.0, blue: 21/255.0, alpha: 1))
        context.addEllipse(in: CGRect(x: -CGFloat(radiusOfCenterCircle), y: -CGFloat(radiusOfCenterCircle), width: CGFloat(centerCircleDiameter), height: CGFloat(centerCircleDiameter)))
        context.fillPath()

        // 画信息条
        let angleIncrement = 2 * .pi / CGFloat(numOfPointBar)
        for barIndex in dotsTable.indices {
            let angle = CGFloat(barIndex) * angleIncrement
            // 起始角度和起始point
            let startDistance = radiusOfCenterCircle + (infoDotsDiameter + infoDotsDiameter / 2)
            let startX = cos(angle) * CGFloat(startDistance)
            let startY = sin(angle) * CGFloat(startDistance)
            // 基于Start的长度
            var length = 1
            var currentStartX = startX
            var currentStartY = startY
 
                        
            func drawInfoBar() {
                //                let color = CGColor(red: 31 / 255, green: 141 / 255, blue: 255 / 255, alpha: 1)
                let gradientColors = colorizer.getGradientColors(length: length)
                let cfGradientColors = gradientColors as CFArray
                let gradientLocations = colorizer.getGradientLocation(length: length)
                
                guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cfGradientColors, locations: gradientLocations) else {
                    fatalError("Could not create gradient")
                }
                
                if length <= 1 {
                    let color = gradientColors.first ?? CGColor(red: 31 / 255, green: 141 / 255, blue: 255 / 255, alpha: 1)
                    context.setFillColor(color)
                    context.addEllipse(in: CGRect(x: currentStartX - CGFloat(infoDotsDiameter / 2), y: currentStartY - CGFloat(infoDotsDiameter / 2), width: CGFloat(infoDotsDiameter), height: CGFloat(infoDotsDiameter)))
                    context.fillPath()
                } else {
                    // 设置线条属性
//                    let color = gradientColors.first ?? CGColor(red: 31 / 255, green: 141 / 255, blue: 255 / 255, alpha: 1)
                    context.setLineWidth(CGFloat(infoDotsDiameter))
                    context.setLineCap(.round)
                    
                    let startPoint = CGPoint(x: currentStartX, y: currentStartY)
                    let endPoint = CGPoint(x: currentStartX + CGFloat(length - 1) * cos(angle) * CGFloat(infoDotsDiameter), y: currentStartY + CGFloat(length - 1) * sin(angle) * CGFloat(infoDotsDiameter))
                    
                    let firstColor = gradientColors.first ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1)
                    context.setFillColor(firstColor)
                    context.addEllipse(in: CGRect(x: startPoint.x - CGFloat(infoDotsDiameter / 2), y: startPoint.y - CGFloat(infoDotsDiameter / 2), width: CGFloat(infoDotsDiameter), height: CGFloat(infoDotsDiameter)))
                    context.fillPath()
                    
                    context.beginPath()
                    context.move(to: startPoint)
                    context.addLine(to: endPoint)
                    
                    context.saveGState()
                    context.replacePathWithStrokedPath()
                    context.clip()
                    context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
                    context.restoreGState()
                    
                    let lastColor = gradientColors.last ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1)
                    context.setFillColor(lastColor)
                    context.addEllipse(in: CGRect(x: endPoint.x - CGFloat(infoDotsDiameter / 2), y: endPoint.y - CGFloat(infoDotsDiameter / 2), width: CGFloat(infoDotsDiameter), height: CGFloat(infoDotsDiameter)))
                    context.fillPath()
                }
            }

            for dotIndex in dotsTable[barIndex].indices {
                let currentDot = dotsTable[barIndex][dotIndex]
                let nextDot: InfoDot? = dotIndex + 1 < dotsTable[barIndex].count ? dotsTable[barIndex][dotIndex + 1] : nil
                var currentDotFlag = false
                var nextDotFlag = false
                
                switch currentDot {
                case .data(let flag):
                    currentDotFlag = flag
                case .function(let flag):
                    currentDotFlag = flag
                case .voidDot:
                    currentDotFlag = false
                }
                
                if let nextDot = nextDot {
                    switch nextDot {
                    case .function(let flag):
                        nextDotFlag = flag
                    case .data(let flag):
                        nextDotFlag = flag
                    case .voidDot:
                        nextDotFlag = false
                    }
                }
                
                if currentDotFlag {
                    if nextDotFlag {
                        length += 1
                    } else {
                        drawInfoBar()
                        currentStartX += cos(angle) * CGFloat(infoDotsDiameter) * CGFloat(length)
                        currentStartY += sin(angle) * CGFloat(infoDotsDiameter) * CGFloat(length)
                        length = 1
                    }
                } else {
                    length = 1
                    currentStartX += cos(angle) * CGFloat(infoDotsDiameter)
                    currentStartY += sin(angle) * CGFloat(infoDotsDiameter)
                }
            }
        }
        
        func drawLocationSymbol(centerX: CGFloat, centerY: CGFloat) {
            let outerDiameter: CGFloat = CGFloat(infoDotsDiameter) * 4 / 5 * 4
            let solidCircleDiameter: CGFloat = CGFloat(infoDotsDiameter) * 4 / 5
            let ringWidth: CGFloat = solidCircleDiameter
            let color = CGColor(red: 255/255, green: 36/255, blue: 66/255, alpha: 1)
            // 画实心圆
            let solidCircleRect = CGRect(
                x: centerX - solidCircleDiameter / 2,
                y: centerY - solidCircleDiameter / 2,
                width: solidCircleDiameter,
                height: solidCircleDiameter)
            context.setFillColor(color)
            context.fillEllipse(in: solidCircleRect)
            print("solidCircleDiameter / 2: \(solidCircleDiameter / 2)")
        
            // 设置线宽和颜色
            context.setLineWidth(ringWidth)
            context.setStrokeColor(color)
            // 画圆环
            let outerRingRect = CGRect(
                x: centerX - outerDiameter / 2,
                y: centerY - outerDiameter / 2,
                width: outerDiameter,
                height: outerDiameter)
            print("outerDiameter / 2: \(outerDiameter / 2)")
            
            print("ringWidth: \(outerDiameter / 2 - solidCircleDiameter / 2 - ringWidth / 2)")

            context.strokeEllipse(in: outerRingRect)
        }
        
        // 从上下文中提取 CGImage
        return context.makeImage()
    }
    
    static func saveImage(image: CGImage, to url: URL) {
        let bitmapRep = NSBitmapImageRep(cgImage: image)
        bitmapRep.size = NSSize(width: image.width, height: image.height)
        
        guard let data = bitmapRep.representation(using: .png, properties: [:]) else {
            return
        }
        
        do {
            try data.write(to: url)
            print("Image saved at \(url.path)")
        } catch {
            print("Failed to save image: \(error)")
        }
    }
}
