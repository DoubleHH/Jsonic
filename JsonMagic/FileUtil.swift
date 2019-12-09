//
//  FileUtil.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/6.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

struct FileUtil {
    static func saveToDisk(fileName: String, content: String) {
        let urlForDocument = FileManager.default.urls(for:.desktopDirectory, in:.userDomainMask)
        let url = urlForDocument[0]
        print(urlForDocument)
        let folderPath = url.appendingPathComponent("models")
        do {
            try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        } catch let e {
            print(e)
            return
        }
        createFile(name:fileName, fileBaseUrl: folderPath, content: content)
    }
    
    static func createFile(name:String, fileBaseUrl:URL, content: String){
        let manager = FileManager.default
        let file = fileBaseUrl.appendingPathComponent(name)
        print("文件: \(file)")
        guard let data = content.data(using: .utf8) else {
            print("content to data failed")
            return
        }
        let createSuccess = manager.createFile(atPath: file.path, contents:data, attributes:nil)
        print("文件创建结果: \(createSuccess)")
    }
}
