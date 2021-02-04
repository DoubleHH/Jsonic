//
//  Modelable.swift
//  JsonMagic
//
//  Created by DoubleHH on 2021/2/4.
//  Copyright © 2021 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

// Generate model class description according to it's definition
protocol Modelable {
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine]) -> String
    func dataTypeDescription(type: Jsonic.DataType) -> String
}
