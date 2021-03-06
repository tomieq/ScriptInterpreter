//
//  Lexer.swift
//
//
//  Created by Tomasz Kucharski on 04/10/2021.
//

import Foundation

enum LexerError: Swift.Error {
    case unknownSyntax(String)
    case invalidRegex(String)
}

extension LexerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownSyntax(let info):
            return NSLocalizedString("LexerError.unknownSyntax: \(info)", comment: "LexerError")
        case .invalidRegex(let info):
            return NSLocalizedString("LexerError.invalidRegex: \(info)", comment: "LexerError")
        }
    }
}

class Lexer {
    let tokens: [Token]

    init(code: String) throws {
        var code = CommentRemover(script: code).cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        var tokens: [Token] = []
        while let match = try Lexer.getNextMatch(code: code) {
            let (resolver, matchingString) = match
            code = String(code[matchingString.endIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let tkns = resolver(matchingString) else {
                fatalError()
            }
            tokens.append(contentsOf: tkns)
        }
        self.tokens = tokens
    }

    private static func getNextMatch(code: String) throws -> (resolver: TokenResolver, matchingString: String)? {
        for tokenGenerator in Token.generators {
            if let matchingString = try code.getMatchingString(regex: tokenGenerator.regex) {
                return (tokenGenerator.resolver, matchingString)
            }
        }
        if code.count != 0 {
            throw LexerError.unknownSyntax("unknown token \(code)")
        }
        return nil
    }
}

fileprivate extension String {
    func getMatchingString(regex: String) throws -> String? {
        if let expression = try? NSRegularExpression(pattern: "^\(regex)", options: []) {
            let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            if range.location == 0 {
                let matchingString = (self as NSString).substring(with: range)
                return matchingString
            }
            return nil
        } else {
            throw LexerError.invalidRegex("Invalid regex: \(regex)")
        }
    }
}
