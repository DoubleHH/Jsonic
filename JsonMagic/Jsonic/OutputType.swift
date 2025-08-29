//
//  File.swift
//  JsonMagic
//
//  Created by DoubleHH on 2020/12/20.
//  Copyright © 2020 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

public enum OutputType {
    public class KotlinConfig: ModelConfigable {
        /// should output SerializedName
        var isSerializedNameEnable: Bool = false
        /// should output JsonProperty
        var isJsonPropertyEnable: Bool = false
        
        convenience init(serializedNameEnable: Bool, jsonPropertyEnable: Bool) {
            self.init()
            isSerializedNameEnable = serializedNameEnable
            isJsonPropertyEnable = jsonPropertyEnable
        }
    }
    
    case swift
    case kotlin(config: KotlinConfig)
    case java
    case objectiveC
    
    internal func fileType() -> String {
        switch self {
        case .kotlin:
            return "kt"
        case .swift:
            return "swift"
        case .java:
            return "java"
        case .objectiveC:
            return "m"
        }
    }
    
    fileprivate func modelDescription(item: Jsonic.DataType) -> String? {
        guard case Jsonic.DataType.object(_, _, _) = item else { return nil }
        switch self {
        case .kotlin(let config):
            return KotlinOutput().modelDescription(objectType: item, config: config)
        case .swift:
            return SwiftOutput().modelDescription(objectType: item, config: nil)
        case .java:
            return JavaOutput().modelDescription(objectType: item, config: nil)
        case .objectiveC:
            return ObjetiveCOutput().modelDescription(objectType: item, config: nil)
        }
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
