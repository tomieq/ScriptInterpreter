//
//  Lexer.swift
//  
//
//  Created by Tomasz Kucharski on 04/10/2021.
//

import Foundation

enum LexerError: Swift.Error {
    case unknownSyntax(String)
}

class Lexer {
    let tokens: [Token]

    init(code: String) throws {
        var code = code.trimmingCharacters(in: .whitespacesAndNewlines)
        var tokens: [Token] = []
        while let match = try Lexer.getNextMatch(code: code) {
            let (regex, matchingString) = match
            code = String(code[matchingString.endIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let generator = Token.generators[regex], let token = generator(matchingString) else {
                fatalError()
            }
            tokens.append(token)
        }
        self.tokens = tokens
    }
    

    private static func getNextMatch(code: String) throws -> (regex: String, matchingString: String)? {
        
        for (regex, _) in Token.generators {
            if let matchingString = code.getMatchingString(regex: regex) {
                return (regex, matchingString)
            }
        }
        if code.count != 0 {
            throw LexerError.unknownSyntax("unknown token \(code)")
        }
        return nil
    }
}

fileprivate extension String {
    func getMatchingString(regex: String) -> String? {
        if let expression = try? NSRegularExpression(pattern: "^\(regex)", options: []) {
            let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            if range.location == 0 {
                let matchingString = (self as NSString).substring(with: range)
                return matchingString
            }
            return nil
        } else {
            fatalError("Invalid regex: \(regex)")
        }
    }
}
