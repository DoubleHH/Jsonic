//
//  Swifty.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/9.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

struct Swifty {
    private static let MODEL_PATTERN = "(data\\s+)?class\\s+\\w+"
    private static let CONCRETE_MODEL_PATTERN = "\\w*Model"
    private static let PROPERTY_NAME_PATTERN = "\"\\w*\""
    private static let PROPERTY_TYPE_PATTERN = "va[rl]\\s+\\w+\\s*:\\s*[\\w,<,>]+"
    
    static func modelFromKotlin(text: String) -> String {
        var result = ""
        let models = splitToMultiModels(text: preprocessText(text: text))
        for modelText in models {
            result += processSingleModel(text: modelText)
        }
        return result
    }
    
    private static func processSingleModel(text: String) -> String {
        let propertyAndNoteMap = computerPropertyAndNoteMap(text: text)
        let lines = text.split(separator: ",")
        var isProcessing: Bool = false
        var result = ""
        for line in lines {
            let item = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if item.isEmpty { continue }
            
            if !isProcessing {
                if let modelName = modelName(line: item) {
                    isProcessing = true
                    result += "class \(modelName): Codable {\n"
                    result += dealPropertyLine(line: item, propertyAndNoteMap: propertyAndNoteMap)
                }
            } else {
                result += dealPropertyLine(line: item, propertyAndNoteMap: propertyAndNoteMap)
            }
            if isProcessing && checkModelEnd(line: item) {
                isProcessing = false
                result += "}\n\n"
            }
        }
        return result
    }
    
    private static func computerPropertyAndNoteMap(text: String) -> [String: String] {
        var result: [String: String] = [:]
        let lines = text.components(separatedBy: "@SerializedName(")
        var isProcessing: Bool = false
        for line in lines {
            let item = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if item.isEmpty { continue }
            
            if !isProcessing {
                if let _ = modelName(line: item) {
                    isProcessing = true
                }
            } else {
                if let pn = dealPropertyToNoteLine(line: line) {
                    result[pn.p] = pn.n
                }
            }
            if isProcessing && checkModelEnd(line: item) {
                isProcessing = false
            }
        }
        return result
    }
    
    private static func dealPropertyToNoteLine(line: String) -> (p: String, n: String)? {
        let lines = line.components(separatedBy: "//")
        if lines.count < 2 || lines[1].isEmpty {
            return nil
        }
        
        guard let propertyType = NSRegularExpression.matches(regex: PROPERTY_TYPE_PATTERN, validateString: line).first?.trimmingCharacters(in: .whitespacesAndNewlines),
        let _ = propertyType.split(separator: ":").last else { return nil }
        
        var pname: String? = nil
        let propertyName = NSRegularExpression.matches(regex: PROPERTY_NAME_PATTERN, validateString: line).first
        if let tempPname = propertyName {
            pname = tempPname.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
        } else {
            pname = propertyType.split(separator: " ")[1].trimmingCharacters(in: .init(charactersIn: ":"))
        }
        
        guard let pname = pname, !pname.isEmpty else { return nil }
        return (p: pname, n: lines[1])
    }
    
    private static func checkModelEnd(line: String) -> Bool {
        return line.hasSuffix(")") || line.contains("{")
    }
    
    private static func splitToMultiModels(text: String) -> [String] {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: MODEL_PATTERN, options: [])
            let matches = regex.matches(in: text, options: [], range: NSMakeRange(0, text.count))
            if matches.count <= 1 {
                return [text]
            }
            var result: [String] = []
            var start = matches[0].range.location
            for index in 1..<matches.count {
                let item = matches[index]
                let end = item.range.location
                if let string = text.partly(from: start, to: end) {
                    result.append(string)
                }
                start = end
            }
            if let string = text.partly(from: start, to: text.count) {
                result.append(string)
            }
            return result
        } catch  {
            return [text]
        }
    }
    
    private static func modelName(line: String) -> String? {
        guard let modelName = NSRegularExpression.matches(regex: MODEL_PATTERN, validateString: line).first else { return nil }
        return NSRegularExpression.matches(regex: CONCRETE_MODEL_PATTERN, validateString: modelName).first
    }
    
    private static func dealPropertyLine(line: String, propertyAndNoteMap: [String: String]) -> String {
        guard let propertyType = NSRegularExpression.matches(regex: PROPERTY_TYPE_PATTERN, validateString: line).first?.trimmingCharacters(in: .whitespacesAndNewlines),
        let ptype = propertyType.split(separator: ":").last else { return "" }
        
        var pname: String? = nil
        let propertyName = NSRegularExpression.matches(regex: PROPERTY_NAME_PATTERN, validateString: line).first
        if let tempPname = propertyName {
            pname = tempPname.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
        } else {
            pname = propertyType.split(separator: " ")[1].trimmingCharacters(in: .init(charactersIn: ":"))
        }
        
        let type = ptype.replacingOccurrences(of: "ArrayList", with: "Array").trimmingCharacters(in: .whitespaces)
        
        if let note = propertyAndNoteMap[pname ?? ""] {
            return "    /// \(note)\n    var \(pname ?? ""): \(type)?\n"
        }
        return "    var \(pname ?? ""): \(type)?\n"
    }
    
    
    private static func preprocessText(text: String) -> String {
        return text.replacingOccurrences(of: "\n", with: "")
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
