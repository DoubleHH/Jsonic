//
//  FormatUtil.swift
//  JsonMagic
//
//  Created by DoubleHH on 2021/2/5.
//  Copyright © 2021 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

class FormatUtil {
    /** Underline format to Camel-Case format */
    static func underlineToCamelCase(name: String) -> String {
        let subs = name.split(separator: "_")
        if subs.count <= 1 {
            return name
        }
        return (subs.first ?? "") + subs.suffix(from: 1).reduce("", { (res, item) -> String in
            return res + item.capitalized
        })
    }
}
