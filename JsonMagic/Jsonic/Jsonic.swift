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


public class Jsonic: NSObject, Logable {
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
    
    internal indirect enum DataType {
        case string, int, long, double, bool, unknown
        case array(itemType: DataType)
        case object(name: String, properties: [PropertyDefine])
    }
    
    internal typealias PropertyDefine = (name: String, type: DataType)
    
    private static let defaultModelSuffix = "Model"
    private var text: String = ""
    /// the top class model name
    private var modelName: String = ""
    /// modle suffix for every class
    var modelSuffix: String = defaultModelSuffix
    private var objectDefines: [DataType] = []
    private weak var delegate: JsonicDelegate?
    internal var logContent: [String] = []
    
    internal func log(_ content: String) {
        print(content)
        logContent.append(content)
    }
    
    /// transfer log info
    var logInfo: String {
        return logContent.joined(separator: "\n")
    }
    
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
        case .kotlin, .java, .objectiveC:
            return modelDesc
        }
        
    }
    
    public init(delegate: JsonicDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    private func tryJsonObject(text: String) -> (jsonObj: Any?, error: Jsonic.JsonicError?) {
        guard let data = text.data(using: .utf8) else {
            return (jsonObj: nil, error: .invalidateText)
        }
        var jsonObj: Any? = nil
        do {
            jsonObj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        } catch let e {
            log("JSONSerialization error: \(e)")
            return (jsonObj: nil, error: .jsonError(e: e))
        }
        return (jsonObj: jsonObj, error: nil)
    }
    
    func beginParse(text: String, modelName: String, modelSuffix: String = defaultModelSuffix) {
        self.text = text
        self.modelName = modelName
        if modelSuffix.isEmpty || modelSuffix == " " {
            self.modelSuffix = Jsonic.defaultModelSuffix
        } else {
            self.modelSuffix = modelSuffix
        }
        objectDefines.removeAll()
        logContent.removeAll()
        
        var jsonObj: Any? = nil
        let originResult = tryJsonObject(text: text)
        if originResult.jsonObj == nil {
            let dealTextResult = cleanText(text: text)
            if !dealTextResult.changed {
                log("No need to remove note")
                delegate?.jsonicDidFinished(success: false, error: originResult.error!)
                return
            }
            log("The text that removed note ============= :\n\(dealTextResult.result)")
            let cleanResult = tryJsonObject(text: dealTextResult.result)
            if cleanResult.jsonObj == nil {
                delegate?.jsonicDidFinished(success: false, error: originResult.error!)
                return
            }
            jsonObj = cleanResult.jsonObj
        } else {
            jsonObj = originResult.jsonObj
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
        let sortedKeys = jsonObject.keys.sorted()
        for key in sortedKeys {
            let type = getDataType(key: key, value: jsonObject[key]!)
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
        
        if case .int = type, (key.hasSuffix("_time") || key.hasSuffix("Time")) {
            type = .long
        }
        
        return type
    }
    
    private func objectName(key: String, appendModelName: Bool = true) -> String {
        let trimedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = appendModelName ? "\(self.modelName)_\(trimedKey)_\(self.modelSuffix)" : "\(trimedKey)_\(self.modelSuffix)"
        return name.split(separator: "_").reduce("") { (res, item) -> String in
            return res + item.pureCapitalized
        }
    }
    
    public func fileName(outputType: OutputType) -> String? {
        guard let last = objectDefines.last, case let Jsonic.DataType.object(name, _) = last else { return nil }
        return name + "." + outputType.fileType()
    }
    
    private func cleanText(text: String) -> (result: String, changed: Bool) {
        let lines = text.split(separator: "\n")
        guard lines.count > 0 else { return (result: text, changed: false) }
        let lineRemoveList = lines.map({ $0.removedNote })
        if lineRemoveList.first(where: { $0.changed }) == nil {
            return (result: text, changed: false)
        }
        return (result: lineRemoveList.map( { $0.result } ).joined(separator: "\n"), changed: true)
    }
}
