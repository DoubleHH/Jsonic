//
//  Swifty.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/9.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

struct Swifty {
    enum Process {
        case none, start, ing, end
    }
    
    private static let DATA_STARTS = "data class"
    private static let MODEL_PATTERN = "\\w*Model"
    private static let PROPERTY_NAME_PATTERN = "\"\\w*\"" //\w*\?
    private static let PROPERTY_TYPE_PATTERN = "\\w*\\?"
    
    static func modelFromKotlin(text: String) {
        let lines = text.split(separator: "\n")
        var process: Process = .none
        for line in lines {
            let item = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if item.isEmpty { continue }
            switch process {
            case .none:
                if item.starts(with: DATA_STARTS), let model = NSRegularExpression.matches(regex: MODEL_PATTERN, validateString: item).first {
                    process = .start
                    print("class \(model): Codable {\n")
                }
            case .start:
                break
            case .ing:
                <#code#>
            case .end:
                <#code#>
            }
        }
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
