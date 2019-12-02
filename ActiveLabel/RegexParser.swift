//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {
    
    static let hashtagPattern = "(?:^|\\s|$)#[\\p{L}0-9_]*"
//    static let mentionPattern = "(?:^|\\s|$|[.])@[\\p{L}0-9_]*"
    static let mentionPattern = "\\u00ad@((?:[^/]+?))\\u00ad"
    // "\\u00ad@((?:[^/]+?))\\u00ad"
//    static let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
//        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
//    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
//    static let urlPattern = "((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[#a-zA-Z0-9\\&%_\\./-~-]*)?"
    static let urlPattern = "<{0,1}(((https|http)?://)?([a-z0-9]+[.])|(www.))"
        + "\\w+[.|\\/]([a-z0-9]{0,})?[[.]([a-z0-9]{0,})]+((/[\\S&&[^,;\\u4E00-\\u9FA5]]+)+)?([.][a-z0-9]{0,}+|/?)>{0,1}"

    
    private static var cachedRegularExpressions: [String : NSRegularExpression] = [:]
    
    static func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }
    
    private static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .ignoreMetacharacters]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }
}
