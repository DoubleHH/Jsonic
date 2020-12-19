//
//  Logable.swift
//  JsonMagic
//
//  Created by DoubleHH on 2020/12/19.
//  Copyright © 2020 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

protocol Logable {
    var logContent: [String] { get }
    func log(_ content: String)
}
