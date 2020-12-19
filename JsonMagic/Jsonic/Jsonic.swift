//
//  Jsonic.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/5.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

public protocol JsonicDelegate: NSObjectProtocol {
    /// transfer did finished
    func jsonicDidFinished(success: Bool, error: Jsonic.JsonicError)
    /// predeal json before transfer json to model
    func jsonicPreprocessJsonBeforeTransfer(json: [String: Any]) -> [String: Any]
}

public class Jsonic: NSObject {
    public enum JsonicError: Error, CustomStringConvertible {
        case none
        case invalidateText
        case notDictionary
        case jsonError(e: Error)
        
        public var description: String {
            switch self {
            case .none:
                return "No error"
            case .invalidateText:
                return "Transfer String to Data failed"
            case .notDictionary:
                return "Transfer String to Dictionary failed"
            case .jsonError(let e):
                return "JSONError: \(e)"
            }
        }
    }
    
    public enum OutputType {
        case swift, kotlin
        
        func fileType() -> String {
            switch self {
            case .kotlin:
                return "kt"
            case .swift:
                return "swift"
            }
        }
    }
    
    fileprivate indirect enum DataType {
        case string, int, double, bool, unknown
        case array(itemType: DataType)
        case object(name: String, properties: [PropertyDefine])
        
        var swiftDescription: String {
            switch self {
            case .string:
                return "String"
            case .int:
                return "Int"
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
        
        var kotlinDescription: String {
            switch self {
            case .string:
                return "String"
            case .int:
                return "Int"
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
    
    fileprivate typealias PropertyDefine = (name: String, type: DataType)
    
    private var text: String = ""
    private var modelName: String = ""
    private var objectDefines: [DataType] = []
    private weak var delegate: JsonicDelegate?
    
    public func modelText(outputType: OutputType) -> String {
        return objectDefines.modelTextForPrint(outputType: outputType)
    }
    
    public func fullModelContext(outputType: OutputType) -> String? {
        guard let last = objectDefines.last, case let DataType.object(name, _) = last else { return nil }
        let modelDesc = objectDefines.modelTextForPrint(outputType: outputType)
        switch outputType {
        case .swift:
            let year = Calendar.current.component(.year, from: Date())
            let content = """
            //
            //  \(name).swift
            //
            //  Copyright © \(year) Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
            //
            """
            return content + "\n\n\n" + modelDesc
        case .kotlin:
            return modelDesc
        }
        
    }
    
    public init(delegate: JsonicDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func beginParse(text: String, modelName: String) {
        self.text = text
        self.modelName = modelName
        objectDefines.removeAll()
        
        guard let data = text.data(using: .utf8) else {
            delegate?.jsonicDidFinished(success: false, error: .invalidateText)
            return
        }
        var jsonObj: Any? = nil
        do {
            jsonObj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        } catch let e {
            print(e)
            delegate?.jsonicDidFinished(success: false, error: .jsonError(e: e))
            return
        }
        guard var json = jsonObj as? [String: Any] else {
            delegate?.jsonicDidFinished(success: false, error: .notDictionary)
            return
        }
        if let delegate = self.delegate {
            json = delegate.jsonicPreprocessJsonBeforeTransfer(json: json)
        }
        let type = DataType.object(name: objectName(key: modelName, appendModelName: false), properties: objectProperties(jsonObject: json))
        objectDefines.append(type)
        delegate?.jsonicDidFinished(success: true, error: .none)
    }
    
    private func objectProperties(jsonObject: [String: Any]) -> [PropertyDefine] {
        var properties: [PropertyDefine] = []
        for (key, value) in jsonObject {
            let type = getDataType(key: key, value: value)
            properties.append((name: key.trimmingCharacters(in: .whitespacesAndNewlines), type: type))
        }
        return properties
    }
    
    private func getDataType(key: String, value: Any) -> DataType {
        var type: DataType = .string
        defer {
            if case DataType.object(_, _) = type {
                objectDefines.append(type)
            }
        }
        switch value {
        case is String:
            type = .string
        case is Int:
            type = .int
        case is Bool:
            type = .bool
        case is Double:
            type = .double
        case is [String: Any]:
            type = .object(name: objectName(key: key), properties: objectProperties(jsonObject: value as! [String: Any]))
        case is Array<Any>:
            if let firstValue = (value as? Array<Any>)?.first {
                type = .array(itemType: getDataType(key: key, value: firstValue))
            } else {
                type = .array(itemType: .string)
            }
        default:
            type = .string
        }
        return type
    }
    
    private func objectName(key: String, appendModelName: Bool = true) -> String {
        let trimedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = appendModelName ? "\(self.modelName)_\(trimedKey)_model" : "\(trimedKey)_model"
        return name.split(separator: "_").reduce("") { (res, item) -> String in
            return res + item.pureCapitalized
        }
    }
    
    public func fileName(outputType: OutputType) -> String? {
        guard let last = objectDefines.last, case let Jsonic.DataType.object(name, _) = last else { return nil }
        return name + "." + outputType.fileType()
    }
}

extension Array where Element == Jsonic.DataType {
    fileprivate func modelTextForPrint(outputType: Jsonic.OutputType) -> String {
        var text = ""
        for item in self {
            if let desc = modelDescription(item: item, outputType: outputType) {
                text += desc + "\n\n"
            }
        }
        return text
    }
    
    private func modelDescription(item: Jsonic.DataType, outputType: Jsonic.OutputType) -> String? {
        guard case let Jsonic.DataType.object(name, properties) = item else { return nil }
        switch outputType {
        case .kotlin:
            return kotlinObjectDesc(name: name, properties: properties)
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
    
    private func kotlinObjectDesc(name: String, properties: [Jsonic.PropertyDefine]) -> String {
        var text = "data class \(name)(\n"
        for (index, property) in properties.enumerated() {
            let serializedName = property.name
            let realName = kotlinPropertyName(name: serializedName)
            text += "   @SerializedName(\"\(serializedName)\") val \(realName): \(property.type.kotlinDescription)? = null"
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
