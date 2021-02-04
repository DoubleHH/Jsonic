//
//  ObjetiveCOutput.swift
//  JsonMagic
//
//  Created by DoubleHH on 2021/2/4.
//  Copyright © 2021 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

class ObjetiveCOutput : Modelable {
    private let objectTypes = ["NSString", "NSArray"]
    private let normalTypes = ["int", "long", "double", "Bool"]
    
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine]) -> String {
        // interface
        var text = "@interface \(name): JSONModel {\n"
        for property in properties {
            let typeDescription = property.type.swiftDescription
            if isObjectType(typeDescrition: typeDescription) {
                text += "@property (nonatomic, strong) \(typeDescription) *\(property.name);\n"
            } else {
                text += "@property (nonatomic, strong) \(typeDescription) \(property.name);\n"
            }
        }
        text += "}"
        
        // implementation
        text +=
            """
            \n\n
            @implementation \(name)
            + (BOOL)propertyIsOptional:(NSString *)propertyName {
                return YES;
            }
            @end
            """
        return text
    }
    
    func dataTypeDescription(type: Jsonic.DataType) -> String {
        switch type {
        case .string:
            return "NSString"
        case .int:
            return "int"
        case .long:
            return "long"
        case .double:
            return "double"
        case .bool:
            return "Bool"
        case .unknown:
            return "NSString"
        case .object(let name, _):
            return name
        case .array(let itemType):
            if case .object(_, _) = itemType {
                return "NSArray<" + itemType.kotlinDescription + ">"
            }
            return "NSArray"
        }
    }
    
    private func isObjectType(typeDescrition: String) -> Bool {
        if objectTypes.contains(where: { $0.hasPrefix(typeDescrition) }) {
            return true
        }
        if !normalTypes.contains(where: { $0.hasPrefix(typeDescrition) }) {
            return true
        }
        return false
    }
}
