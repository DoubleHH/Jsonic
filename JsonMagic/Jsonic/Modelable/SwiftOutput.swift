//
//  SwiftOutput.swift
//  JsonMagic
//
//  Created by DoubleHH on 2021/2/5.
//  Copyright © 2021 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

class SwiftOutput: Modelable {
    typealias ModelConfig = DefaultModelConfig
    
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine], config: DefaultModelConfig?) -> String {
        var text = "class \(name): Codable {\n"
        for property in properties {
            text += "    var \(property.name): \(property.type.swiftDescription)?\n"
        }
        text += "}"
        return text
    }
    
    func dataTypeDescription(type: Jsonic.DataType) -> String {
        switch type {
        case .string:
            return "String"
        case .int:
            return "Int"
        case .long:
            return "Int64"
        case .double:
            return "Double"
        case .bool:
            return "Bool"
        case .unknown:
            return "String"
        case .object(let name, _):
            return name
        case .array(let itemType):
            return "Array<" + itemType.swiftDescription + ">"
        }
    }
}
