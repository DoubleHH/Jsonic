//
//  JavaOutput.swift
//  JsonMagic
//
//  Created by DoubleHH on 2021/2/5.
//  Copyright © 2021 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

class JavaOutput: Modelable {
    typealias ModelConfig = DefaultModelConfig
    
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine], config: DefaultModelConfig?) -> String {
        var text =
            """
            @Data
            @NoArgsConstructor
            @AllArgsConstructor\n
            """
        text += "public class \(name) {\n"
        for (index, property) in properties.enumerated() {
            text += "    @JsonProperty(\"\(property.name)\")\n"
            let camelCaseName = FormatUtil.underlineToCamelCase(name: property.name)
            text += "    private \(property.type.javaDescription) \(camelCaseName));\n"
            if index < properties.count - 1 {
                text += "\n"
            }
        }
        text += "}"
        return text
    }
    
    func dataTypeDescription(type: Jsonic.DataType) -> String {
        switch type {
        case .string:
            return "String"
        case .int:
            return "Integer"
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
            return "List<" + itemType.kotlinDescription + ">"
        }
    }
}
