//
//  YapiJsonModel.swift
//  JsonMagic
//
//  Created by 黄辉(HuiHuang) on 2025/8/29.
//  Copyright © 2025 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

enum YapiType: String, Codable {
    case string, number, integer, array, object
}

class YapiJsonModel: Codable {
    var description: String?
    var type: YapiType?
    var properties: [String: YapiJsonModel]?
    var items: YapiJsonModel?
}
