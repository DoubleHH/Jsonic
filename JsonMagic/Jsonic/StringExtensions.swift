//
//  StringExtensions.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/5.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

extension String.SubSequence {
    /// substring with range. If range is illeagal, return nil
    ///
    /// - Parameter range: indicate start and end. like 0..<2
    /// - Returns: sub or nil
    public func partly(range: Range<Int>) -> String? {
        return partly(from: range.lowerBound, to: range.upperBound)
    }
    
    /// substring from index
    public func partly(from: Int) -> String? {
        return partly(from: from, to: self.count)
    }
    
    /// substring with end index of (to - 1), from 0
    public func partly(to: Int) -> String? {
        return partly(from: 0, to: to)
    }
    
    public func partly(from: Int, to: Int) -> String? {
        guard from >= 0, to <= self.count, from < to else { return nil }
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[fromIndex..<toIndex])
    }
}

/// substring
extension String {
    
    /// substring with range. If range is illeagal, return nil
    ///
    /// - Parameter range: indicate start and end. like 0..<2
    /// - Returns: sub or nil
    public func partly(range: Range<Int>) -> String? {
        return partly(from: range.lowerBound, to: range.upperBound)
    }
    
    /// substring from index
    public func partly(from: Int) -> String? {
        return partly(from: from, to: self.count)
    }
    
    /// substring with end index of (to - 1), from 0
    public func partly(to: Int) -> String? {
        return partly(from: 0, to: to)
    }
    
    public func partly(from: Int, to: Int) -> String? {
        guard from >= 0, to <= self.count, from < to else { return nil }
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[fromIndex..<toIndex])
    }
}

extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange? {
        guard let from = range.lowerBound.samePosition(in: utf16) else { return nil }
        guard let to = range.upperBound.samePosition(in: utf16) else { return nil }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
    
    func nsRange(string: String) -> NSRange? {
        guard let range = range(of: string) else { return nil }
        return nsRange(from: range)
    }
}

extension String {
    var pureCapitalized: String {
        guard count > 0 else { return "" }
        return partly(to: 1)?.capitalized.appending(partly(from: 1) ?? "") ?? ""
    }
}

extension String.SubSequence {
    var pureCapitalized: String {
        guard count > 0 else { return "" }
        return partly(to: 1)?.capitalized.appending(partly(from: 1) ?? "") ?? ""
    }
}

extension String.SubSequence {
    /// the string removed note
    var removedNote: (result: Self, changed: Bool) {
        let reg = "//.*"
        let res = self.range(of: reg, options: .regularExpression, range: self.startIndex ..< self.endIndex, locale: Locale.current)
        guard let range = res else {
            return (result: self, false)
        }
        let prefix = self[startIndex..<range.lowerBound]
        let prefixCount = prefix.filter( { $0 == "\"" }).count
        let suffixCount = self[range].filter( { $0 == "\"" }).count
        if (suffixCount % 2) == 1 && (prefixCount % 2) == 1 {
            return (result: self, false)
        }
        return (result: prefix, true)
    }
}
