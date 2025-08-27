//
//  RCCoder.swift
//
//
//  Created by 谢恩平 on 2024/12/30.
//

import Foundation

class RCCoder {
    static func encodeString(input: String) -> [Bool]? {
        // UTF-8 编码转换
        if let utf8Data = input.data(using: .utf8) {
            // 初始化布尔数组
            var boolArray = [Bool]()

            // 遍历每一个字节
            for byte in utf8Data {
                // 遍历每个字节中的每一位
                for i in 0..<8 {
                    // 将字节的每一位转化为布尔值，并加入数组
                    let bit = (byte & (1 << i)) != 0
                    boolArray.append(bit)
                }
            }
            return boolArray

        } else {
            print("无法转换字符串为 UTF-8 编码数据")
            return nil
        }
    }
}
