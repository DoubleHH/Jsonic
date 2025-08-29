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
    
    func modelDescription(objectType: Jsonic.DataType, config: ModelConfig?) -> String {
        guard case Jsonic.DataType.object(let name, let properties, let note) = objectType else { return "" }
        var text = ""
        if !note.isEmpty {
            text += "// \(note)\n"
        }
        text +=
            """
            @Data
            @NoArgsConstructor
            @AllArgsConstructor\n
            """
        text += "public class \(name) {\n"
        for (index, property) in properties.enumerated() {
            text += "    @JsonProperty(\"\(property.name)\")\n"
            let typeDescription = dataTypeDescription(type: property.type)
            let camelCaseName = FormatUtil.underlineToCamelCase(name: property.name)
            if !property.note.isEmpty {
                text += "    // \(property.note)\n"
            }
            text += "    private \(typeDescription) \(camelCaseName));\n"
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
        case .object(let name, _, _):
            return name
        case .array(let itemType):
            let typeDescription = dataTypeDescription(type: itemType)
            return "List<" + typeDescription + ">"
        }
    }
}
