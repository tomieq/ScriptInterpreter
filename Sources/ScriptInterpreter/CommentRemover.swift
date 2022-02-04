//
//  CommentRemover.swift
//  
//
//  Created by Tomasz Kucharski on 04/02/2022.
//

import Foundation

class CommentRemover {
    private let original: String
    var cleaned: String {
        var copy = self.original
        copy = self.removeByRegex(input: copy, regex: "/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/")
        copy = self.removeByRegex(input: copy, regex: "\\/\\/([^\\r\\n]*)")
        return copy
    }
    
    init(script: String) {
        self.original = script
    }
    
    private func removeByRegex(input: String, regex: String) -> String {
        do {
            let expression = try NSRegularExpression(pattern: regex, options: [])
            let range = NSMakeRange(0, input.utf16.count)
            return expression.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: " ")
        } catch {
            print(error.localizedDescription)
        }
        return input
    }
}
