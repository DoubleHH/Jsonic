//
//  KotlinOutput.swift
//  JsonMagic
//
//  Created by DoubleHH on 2021/2/5.
//  Copyright © 2021 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

class KotlinOutput: Modelable {
    typealias ModelConfig = OutputType.KotlinConfig
    
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine], config: OutputType.KotlinConfig?) -> String {
        var text = "data class \(name)(\n"
        for (index, property) in properties.enumerated() {
            let serializedName = property.name
            let realName = FormatUtil.underlineToCamelCase(name: serializedName)
            text += "   "
            if let cfg = config {
                if cfg.isJsonPropertyEnable {
                    text += "@JsonProperty(\"\(serializedName)\") "
                }
                if cfg.isSerializedNameEnable {
                    text += "@SerializedName(\"\(serializedName)\") "
                }
            }
            let typeDescription = dataTypeDescription(type: property.type)
            text += "val \(realName): \(typeDescription)? = null"
            if index < properties.count - 1 {
                text += ","
            }
            text += "\n"
        }
        text += ")"
        return text
    }
    
    func dataTypeDescription(type: Jsonic.DataType) -> String {
        switch type {
        case .string:
            return "String"
        case .int:
            return "Int"
        case .long:
            return "Long"
        case .double:
            return "Double"
        case .bool:
            return "Boolean"
        case .unknown:
            return "String"
        case .object(let name, _):
            return name
        case .array(let itemType):
            let typeDescription = dataTypeDescription(type: itemType)
            return "List<" + typeDescription + ">"
        }
    }
}
