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
    
    func modelDescription(objectType: Jsonic.DataType, config: ModelConfig?) -> String {
        guard case Jsonic.DataType.object(let name, let properties, let note) = objectType else { return "" }
        var text = ""
        if !note.isEmpty {
            text += "/// \(note)\n"
        }
        text += "class \(name): Codable {\n"
        for property in properties {
            let typeDescription = dataTypeDescription(type: property.type)
            if !property.note.isEmpty {
                text += "    /// \(property.note)\n"
            }
            text += "    var \(property.name): \(typeDescription)?\n"
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
        case .object(let name, _, _):
            return name
        case .array(let itemType):
            let typeDescription = dataTypeDescription(type: itemType)
            return "Array<" + typeDescription + ">"
        }
    }
}
