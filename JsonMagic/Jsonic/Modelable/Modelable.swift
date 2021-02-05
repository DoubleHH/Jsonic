//
//  Modelable.swift
//  JsonMagic
//
//  Created by DoubleHH on 2021/2/4.
//  Copyright © 2021 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

/** Model Config protocol */
protocol ModelConfigable { }

/** Default config */
internal class DefaultModelConfig: ModelConfigable { }

// Generate model class description according to it's definition
protocol Modelable {
    associatedtype ModelConfig
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine], config: ModelConfig?) -> String
    func dataTypeDescription(type: Jsonic.DataType) -> String
}
