//
//  ActiveBuilder.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = ((String) -> Bool)

struct ActiveBuilder {
    
    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .url, .lookMore:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .custom:
            return createElements(from: text, for: type, range: range, minLength: 1, filterPredicate: filterPredicate)
        }
        
    }
    
    // 创建 url 事件
    static func createURLElements(from text: String, range: NSRange, maximumLenght: Int?) -> ([ElementTuple], String) {
        let type = ActiveType.url
        var text = text // 原 string
        // 用正则检查是否有 url
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        var matchInfos: [(String, NSRange)] = []
        for match in matches where match.range.length > 2 {
            // url 字段
            let webString = nsstring.substring(with: match.range).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            matchInfos.append((webString, match.range))
        }
        
        let trimmedWord = "网页链接"
        var oldRecord = 0
        var newRecord = 0
        for (webString, webRange) in matchInfos {
            // 计算 range
            let newRangeLocation = webRange.location - oldRecord + newRecord
            let newRangeLenth = (trimmedWord as NSString).length
            let newRange = NSRange(location: newRangeLocation, length: newRangeLenth)
            oldRecord += (webString as NSString).length
            newRecord += newRangeLenth
            // 设置 element
            let element = ActiveElement.url(original: webString, trimmed: trimmedWord)
            text = text.replacingOccurrences(of: webString, with: trimmedWord)
            elements.append((newRange, element, type))
            
        }
        return (elements, text)
    }
    
    // 创建 url 事件
    static func createLookMoreElements(from text: String, range: NSRange, maximumLenght: Int?) -> ([ElementTuple], String) {
        let type = ActiveType.lookMore
        var text = text // 原 string
        // 用正则检查是否有 url
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        var matchInfos: [(String, NSRange)] = []
        for match in matches where match.range.length > 2 {
            // url 字段
            let webString = nsstring.substring(with: match.range).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            matchInfos.append((webString, match.range))
        }
        
        let trimmedWord = "阅读全文    "
        var oldRecord = 0
        var newRecord = 0
        for (webString, webRange) in matchInfos {
            // 计算 range
            let newRangeLocation = webRange.location - oldRecord + newRecord
            let newRangeLenth = (trimmedWord as NSString).length
            let newRange = NSRange(location: newRangeLocation, length: newRangeLenth)
            oldRecord += (webString as NSString).length
            newRecord += newRangeLenth
            // 设置 element
            let element = ActiveElement.url(original: webString, trimmed: trimmedWord)
            text = text.replacingOccurrences(of: webString, with: trimmedWord)
            elements.append((newRange, element, type))
            
        }
        return (elements, text)
    }
    
    private static func createElements(from text: String,
                                       for type: ActiveType,
                                       range: NSRange,
                                       minLength: Int = 2,
                                       filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > minLength {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
    
    private static func createElementsIgnoringFirstCharacter(from text: String,
                                                             for type: ActiveType,
                                                             range: NSRange,
                                                             filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > 2 {
            let range = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") {
                word.remove(at: word.startIndex)
            }
            else if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }
            
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
}
