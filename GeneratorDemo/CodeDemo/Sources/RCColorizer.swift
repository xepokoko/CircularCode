//
//  RCColorizer.swift
//
//
//  Created by 谢恩平 on 2024/12/31.
//

import Foundation
import CoreGraphics

class RCColorizer {
    // 渐变颜色表
    private let colorTable = [CGColor(red: 251 / 255, green: 183 / 255, blue: 58 / 255, alpha: 1),
                      CGColor(red: 244 / 255, green: 155 / 255, blue: 0, alpha: 1),
                      CGColor(red: 204 / 255, green: 190 / 255, blue: 15 / 255, alpha: 1),
                      CGColor(red: 26 / 255, green: 190 / 255, blue: 77 / 255, alpha: 1),
                      CGColor(red: 10 / 255, green: 173 / 255, blue: 255 / 255, alpha: 1),
                      CGColor(red: 38 / 255, green: 130 / 255, blue: 255 / 255, alpha: 1),
                      CGColor(red: 171 / 255, green: 87 / 255, blue: 255 / 255, alpha: 1),
                      CGColor(red: 255 / 255, green: 0, blue: 111 / 255, alpha: 1)]
    
    // 颜色 index
    private var currentStartColorIndex = 0
    
    public func getGradientColors(length: Int) -> [CGColor] {
        let pointNumPerGroup = 4
        let groupNum = length / pointNumPerGroup
        let remainder = length % pointNumPerGroup
        var result = [CGColor]()
        for _ in 0..<groupNum {
            result.append(contentsOf: getTwoColors())
        }
        if remainder > 0, remainder <= 2 {
            result.append(contentsOf: getOneColor())
        } else if remainder > 2 {
            result.append(contentsOf: getTwoColors())
        }

        return result
    }
    
    public func getGradientLocation(length: Int) -> [CGFloat] {
        let trueLength = CGFloat(length) * 20
        var result = [CGFloat]()
        for i in 1...length {
            if i == 1 {
                result.append(0.0)
                continue
            }
            if i == length {
                result.append(1.0)
                continue
            }
            if i % 4 == 0 {
                result.append((CGFloat(i) * 20 - 10) / trueLength)
            } else if i > 4, i % 4 == 1 {
                result.append((CGFloat(i) * 20 - 10) / trueLength)
            }
        }

        return result
    }
    
    private func getOneColor() -> [CGColor] {
        if currentStartColorIndex < colorTable.count {
            let color = colorTable[currentStartColorIndex]
            currentStartColorIndex = (currentStartColorIndex + 2) % colorTable.count
            return [color]
        }
        print("颜色数组下标超阈")
        return []
    }
    
    private func getTwoColors() -> [CGColor] {
        if currentStartColorIndex < colorTable.count {
            let color1 = colorTable[currentStartColorIndex]
            currentStartColorIndex = (currentStartColorIndex + 1) % colorTable.count
            let color2 = colorTable[currentStartColorIndex]
            currentStartColorIndex = (currentStartColorIndex + 1) % colorTable.count
            return [color1, color2]
        }
        print("颜色数组下标超阈")
        return []
    }
}
