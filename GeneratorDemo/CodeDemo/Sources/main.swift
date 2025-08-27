//
//  File.swift
//  CodeDemo
//
//  Created by 谢恩平 on 2024/12/16.
//


import Foundation

// 解析外部传进来的参数
let arguments = CommandLine.arguments

guard arguments.count == 4,
      let infoDotsDiameter = Int(arguments[1]) else {
    print("Usage: program_name <infoDotsDiameter> <imageName> <inputString>")
    exit(1)
}

let imageName = "AARCCode/\(arguments[2]).png"
let inputString = String(arguments[3])

let fileManager = FileManager.default

let shapeInfo = RCShapeInfo()

let model = InfoDotsModel(shapeInfo: shapeInfo)
let dataEncodeList = RCCoder.encodeString(input: inputString)
model.updateModel(encodeDataList: dataEncodeList ?? [])

if let image = ImageGenerator.createImage(infoDotsDiameter: infoDotsDiameter, model: model) {
    if let downloadsDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first {
        let url = downloadsDirectory.appendingPathComponent(imageName)
        ImageGenerator.saveImage(image: image, to: url)
    } else {
        print("找不到“下载”路径")
    }
} else {
    print("Could not create image.")
}



