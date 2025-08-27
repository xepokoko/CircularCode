//
//  InfoDotsModel.swift
//
//
//  Created by 谢恩平 on 2024/12/26.
//

import Foundation

class InfoDotsModel {
    static private let locationSymbolVoidDotBar = [13, 14, 22, 23, 31, 32]
    static private func isVoidDot(i: Int, j: Int) -> Bool {
        // logo 处的空点
        if (i == 4 || i == 5) && j >= 10 {
            return true
        }
        
        // 定位符号处的空点
        if locationSymbolVoidDotBar.contains(where: { bar in
            bar == i
        }), j >= 11, j <= 14 {
            return true
        }
        return false
    }
    static private func isFunctionDot(i: Int, j: Int) -> Bool {
        guard !isVoidDot(i: i, j: j) else {
             return false
        }
        if j == 0 {
            return true
        }
        return false
    }
    
    var shapeInfo: RCShapeInfo
    private(set) var dotsTable: [[InfoDot]]
    
    init(shapeInfo: RCShapeInfo) {
        self.shapeInfo = shapeInfo
        var newDotsTable = [[InfoDot]]()
        for i in 0..<shapeInfo.numOfPointBar {
            var dots = [InfoDot]()
            for j in 0..<shapeInfo.maxCountOfInfoDotsPerBar {
                if InfoDotsModel.isVoidDot(i: i, j: j) {
                    let dot = InfoDot.voidDot
                    dots.append(dot)
                    continue
                }
                
                if InfoDotsModel.isFunctionDot(i: i, j: j) {
                    let dot = InfoDot.function(false)
                    dots.append(dot)
                    continue
                }
                
                let dot = InfoDot.data(false)
                dots.append(dot)
            }
            newDotsTable.append(dots)
        }
        dotsTable = newDotsTable
    }
    
    public func updateModel(encodeDataList: [Bool]) {
        guard encodeDataList.count <= 504 else {
            print("码数超过 504")
            fatalError()
        }
        var encodeDataList = encodeDataList
        var functionDots = generateFunctionDots(maskNum: 1, errorCorrectionLevelNum: 1, dataDotsLengthNum: encodeDataList.count)
        var newTable = dotsTable
        let mask = testMask()
        traverseDotsTable { i, j in
            guard !functionDots.isEmpty else {
                return
            }
            let functionDotFlag = functionDots.removeFirst()
            let maskFlag = mask[i][j]
            
            let dot = InfoDot.function(functionDotFlag != maskFlag)
            newTable[i][j] = dot
        } handleDataDots: { i, j in
            guard !encodeDataList.isEmpty else {
                let maskFlag = mask[i][j]
                let dot = InfoDot.data(maskFlag != false)
                newTable[i][j] = dot
                return
            }
            let maskFlag = mask[i][j]
            let encodeDataFlag = encodeDataList.removeFirst()
            let dot = InfoDot.data(encodeDataFlag != maskFlag)
            newTable[i][j] = dot
        }

        dotsTable = newTable
    }
    
    func traverseDotsTable(handleVoidDots: ((Int, Int) -> ())? = nil, handleFuctionDots: ((Int, Int) -> ())?, handleDataDots: ((Int, Int) -> ())?) {
        for i in dotsTable.indices {
            for j in dotsTable[i].indices {
                if InfoDotsModel.isVoidDot(i: i, j: j) {
                    if let handleVoidDots = handleVoidDots {
                        handleVoidDots(i, j)
                    }
                } else if InfoDotsModel.isFunctionDot(i: i, j: j) {
                    if let handleFuctionDots = handleFuctionDots {
                        handleFuctionDots(i, j)
                    }
                } else {
                    if let handleDataDots = handleDataDots {
                        handleDataDots(i, j)
                    }
                }
            }
        }
    }
    
    func generateFunctionDots(maskNum: Int, errorCorrectionLevelNum: Int, dataDotsLengthNum: Int) -> [Bool] {
        // 掩码号
        let mask = intToFixedLengthBinaryBoolArray(maskNum, length: 2)
        // 纠错码等级
        let errorCorrectionLevel = intToFixedLengthBinaryBoolArray(errorCorrectionLevelNum, length: 5)
        // 数据码长度
        let dataDotsLength = intToFixedLengthBinaryBoolArray(dataDotsLengthNum, length: 9)
        // 保留点位
        let reserve = [true, true]
        // 一组功能点
        let functionGroup = mask + errorCorrectionLevel + dataDotsLength + reserve
        // 最终的功能点位集合
        let funciontDots = functionGroup + functionGroup
        return funciontDots
    }
    
    func intToFixedLengthBinaryBoolArray(_ number: Int, length: Int) -> [Bool] {
        // 将 Int 转为二进制 String
        let binaryString = String(number, radix: 2)
        
        // 计算需要补几个0在数组前
        let missingZeros = max(0, length - binaryString.count)
        
        // 补充的 0 和实际数据拼接
        let boolArray = [Bool](repeating: false, count: missingZeros) + binaryString.map { $0 == "1" }
        
        // 保证不超过 length
        return Array(boolArray.prefix(length))
    }
    
    // 测试掩码，后续完善
    func testMask() -> [[Bool]] {
        var mask: [[Bool]] = Array(repeating: Array(repeating: false, count: 16), count: 36)
        for x in 0..<shapeInfo.numOfPointBar {
            for y in 0..<shapeInfo.maxCountOfInfoDotsPerBar {
                if (x / 4) % 2 == 0 {
                    mask[x][y] = true
                } else {
                    mask[x][y] = false
                }
            }
        }
        return mask
    }
}

enum InfoDot {
    /// 功能点
    case function(Bool)
    /// 数据点
    case data(Bool)
    /// 空点
    case voidDot
}



