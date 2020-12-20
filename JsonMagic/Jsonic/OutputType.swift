//
//  File.swift
//  JsonMagic
//
//  Created by DoubleHH on 2020/12/20.
//  Copyright © 2020 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

public enum OutputType {
    public struct KotlinConfig {
        /// should output SerializedName
        var isSerializedNameEnable: Bool
        /// should output JsonProperty
        var isJsonPropertyEnable: Bool
    }
    
    case swift
    case kotlin(config: KotlinConfig)
    
    internal func fileType() -> String {
        switch self {
        case .kotlin:
            return "kt"
        case .swift:
            return "swift"
        }
    }
    
    fileprivate func modelDescription(item: Jsonic.DataType) -> String? {
        guard case let Jsonic.DataType.object(name, properties) = item else { return nil }
        switch self {
        case .kotlin(let config):
            return kotlinObjectDesc(name: name, properties: properties, config: config)
        case .swift:
            return swiftObjectDesc(name: name, properties: properties)
        }
    }
    
    private func swiftObjectDesc(name: String, properties: [Jsonic.PropertyDefine]) -> String {
        var text = "class \(name): Codable {\n"
        for property in properties {
            text += "    var \(property.name): \(property.type.swiftDescription)?\n"
        }
        text += "}"
        return text
    }
    
    private func kotlinObjectDesc(name: String, properties: [Jsonic.PropertyDefine], config: KotlinConfig) -> String {
        var text = "data class \(name)(\n"
        for (index, property) in properties.enumerated() {
            let serializedName = property.name
            let realName = kotlinPropertyName(name: serializedName)
            text += "   "
            if config.isJsonPropertyEnable {
                text += "@JsonProperty(\"\(serializedName)\") "
            }
            if config.isSerializedNameEnable {
                text += "@SerializedName(\"\(serializedName)\") "
            }
            text += "val \(realName): \(property.type.kotlinDescription)? = null"
            if index < properties.count - 1 {
                text += ","
            }
            text += "\n"
        }
        text += ")"
        return text
    }
    
    private func kotlinPropertyName(name: String) -> String {
        let subs = name.split(separator: "_")
        if subs.count <= 1 {
            return name
        }
        return (subs.first ?? "") + subs.suffix(from: 1).reduce("", { (res, item) -> String in
            return res + item.capitalized
        })
    }
}

internal extension Array where Element == Jsonic.DataType {
    func modelTextForPrint(outputType: OutputType) -> String {
        var text = ""
        for item in self {
            if let desc = outputType.modelDescription(item: item) {
                text += desc + "\n\n"
            }
        }
        return text
    }
}
