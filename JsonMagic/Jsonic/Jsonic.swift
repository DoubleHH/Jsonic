//
//  Jsonic.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/5.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

public protocol JsonicDelegate: NSObjectProtocol {
    func jsonicDidFinished(success: Bool, error: Jsonic.JsonicError)
    func jsonicPreprocessJson(json: [String: Any]) -> [String: Any]
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
    
    fileprivate indirect enum DataType: CustomStringConvertible {
        case string, int, double, bool, unknown
        case array(itemType: DataType)
        case object(name: String, properties: [PropertyDefine])
        
        var description: String {
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
                return "Array<" + itemType.description + ">"
            }
        }
    }
    
    fileprivate typealias PropertyDefine = (name: String, type: DataType)
    
    private var text: String = ""
    private var modelName: String = ""
    private var objectDefines: [DataType] = []
    private weak var delegate: JsonicDelegate?
    
    var modelText: String {
        return objectDefines.modelTextForPrint()
    }
    var fullModelContext: String? {
        guard let last = objectDefines.last, case let DataType.object(name, _) = last else { return nil }
        let content = """
        //
        //  \(name).swift
        //
        //  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
        //
        """
        return content + "\n\n\n" + objectDefines.modelTextForPrint()
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
            json = delegate.jsonicPreprocessJson(json: json)
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
            print(value)
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
            return res + item.capitalized
        }
    }
    
    public func swiftFileName() -> String? {
        guard let last = objectDefines.last, case let Jsonic.DataType.object(name, _) = last else { return nil }
        return name + ".swift"
    }
}

extension Array where Element == Jsonic.DataType {
    fileprivate func modelTextForPrint() -> String {
        var text = ""
        for item in self {
            if let desc = modelDescription(item: item) {
                text += desc + "\n\n"
            }
        }
        return text
    }
    
    private func modelDescription(item: Jsonic.DataType) -> String? {
        guard case let Jsonic.DataType.object(name, properties) = item else { return nil }
        var text = "class \(name): Codable {\n"
        for property in properties {
            text += "    var \(property.name): \(property.type.description)?\n"
        }
        text += "}"
        return text
    }
}
