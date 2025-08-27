//
//  RedCodeShapeInfo.swift
//
//
//  Created by 谢恩平 on 2024/12/17.
//

import Foundation

class RCShapeInfo {
    /// 信息点直径
    var infoDotsDiameter = 20
    
    /// 二维码范围的边长（正方形边长）
    var lengthOfCRange: Int {
        infoDotsDiameter * 48
    }
    
    /// 中心圆的直径
    var centerCircleDiameter: Int {
        infoDotsDiameter * 14
    }
    
    /// 信息条的数量（从中心往外发射的条）
    var numOfPointBar = 36
    
    /// 定位符号的直径
    var locatonSymbolDiamenter: Int {
        infoDotsDiameter * 4
    }
    
    /// 一个信息条最大信息点数
    var maxCountOfInfoDotsPerBar = 16
    
    /// logo 的size
    var sizeOfLogo: CGSize {
        CGSize(width: CGFloat(infoDotsDiameter) * 6.5, height: CGFloat(infoDotsDiameter) * 6.5)
    }
    
    var positionOfLocatonSymbols: (northwestCenterPos: CGPoint, southwestCenterPos: CGPoint, southeastCenterPos: CGPoint) {
        let sin45Degrees = sin(45.0 * Double.pi / 180.0)

        // 二维码圆形区域半径
        let radius = CGFloat(lengthOfCRange) / 2

        // 二维码半径乘 tan45
        let sin45Radius = radius  * sin45Degrees

        let x1 = radius - sin45Radius + CGFloat(locatonSymbolDiamenter) / 2
        let y1 = radius - sin45Radius + CGFloat(locatonSymbolDiamenter) / 2
        // 西南角的定位符
        let southwestCenterPos = CGPoint(x: x1, y: y1)

        let x2 = x1
        let y2 = CGFloat(lengthOfCRange) - (CGFloat(lengthOfCRange) / 2 - sin45Radius + CGFloat(locatonSymbolDiamenter) / 2)
        // 西北角的定位符
        let northwestCenterPos = CGPoint(x: x2, y: y2)

        
        let x3 = CGFloat(lengthOfCRange) - (CGFloat(lengthOfCRange) / 2 - sin45Radius + CGFloat(locatonSymbolDiamenter) / 2)
        let y3 = y1
        // 东南角的定位符
        let southeastCenterPos = CGPoint(x: x3, y: y3)

        return (northwestCenterPos, southwestCenterPos, southeastCenterPos)
    }
    
}
