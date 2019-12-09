//
//  Swifty.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/9.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

struct Swifty {
    
    private static let DATA_STARTS = "data class"
    private static let PROPERTY_STARTS = "@SerializedName("
    
    private static let MODEL_PATTERN = "data\\s*class\\s*\\w*Model"
    private static let CONCRETE_MODEL_PATTERN = "\\w*Model"
    private static let PROPERTY_NAME_PATTERN = "\"\\w*\""
    private static let PROPERTY_TYPE_PATTERN = "val\\s*\\w*\\s*:\\s*[\\w,<,>]*"
    
    static func modelFromKotlin(text: String) -> String {
        let lines = preprocessText(text: text).split(separator: ",")
        var isProcessing: Bool = false
        var result = ""
        for line in lines {
            let item = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if item.isEmpty { continue }
            
            if !isProcessing {
                if let modelName = modelName(line: item) {
                    isProcessing = true
                    result += "class \(modelName): Codable {\n"
                    result += dealPropertyLine(line: item)
                    
                    if checkModelEnd(line: item) {
                        isProcessing = false
                        result += "}\n\n"
                    }
                }
            } else {
                result += dealPropertyLine(line: item)
                
                if checkModelEnd(line: item) {
                    isProcessing = false
                    result += "}\n\n"
                }
                
                // maybe has model
                if let modelName = modelName(line: item) {
                    isProcessing = true
                    result += "class \(modelName): Codable {\n"
                    
                    let arr = item.components(separatedBy: modelName)
                    if let last = arr.last {
                        result += dealPropertyLine(line: last)
                    }
                }
            }
        }
        return result
    }
    
    private static func checkModelEnd(line: String) -> Bool {
        return line.hasSuffix(")") || line.contains("{")
    }
    
    private static func modelName(line: String) -> String? {
        guard let modelName = NSRegularExpression.matches(regex: MODEL_PATTERN, validateString: line).first else { return nil }
        return NSRegularExpression.matches(regex: CONCRETE_MODEL_PATTERN, validateString: modelName).first
    }
    
    private static func dealPropertyLine(line: String) -> String {
        guard let propertyName = NSRegularExpression.matches(regex: PROPERTY_NAME_PATTERN, validateString: line).first,
            let propertyType = NSRegularExpression.matches(regex: PROPERTY_TYPE_PATTERN, validateString: line).first?.trimmingCharacters(in: .whitespacesAndNewlines),
            let ptype = propertyType.split(separator: ":").last else { return "" }
        let pname = propertyName.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
        let type = ptype.replacingOccurrences(of: "ArrayList", with: "Array").trimmingCharacters(in: .whitespaces)
        return "    var \(pname): \(type)?\n"
    }
    
    
    private static func preprocessText(text: String) -> String {
        return text.replacingOccurrences(of: "\n", with: "")
    }
    
    static func findResult() {
        let text = "@SerializedName(\"station_id\") val stationId: String? = null,"
        let pattern = ""
        print(NSRegularExpression.matches(regex: pattern, validateString: text))
    }
}

extension NSRegularExpression {
    /// 正则匹配
    ///
    /// - Parameters:
    ///   - regex: 匹配规则
    ///   - validateString: 匹配对test象
    /// - Returns: 返回结果
    static func matches(regex:String, validateString:String) -> [String] {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: validateString, options: [], range: NSMakeRange(0, validateString.count))
            var data:[String] = []
            for item in matches {
                let string = (validateString as NSString).substring(with: item.range)
                data.append(string)
            }
            return data
        }
        catch {
            return []
        }
    }
}
