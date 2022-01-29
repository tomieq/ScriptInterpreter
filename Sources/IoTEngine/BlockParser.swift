//
//  BlockParser.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation

enum BlockParserError: Error {
    case invalidTokenPosition(found: Token?, expected: Token)
}

extension BlockParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTokenPosition(let found, let expected):
            return NSLocalizedString("BlockParserError.invalidTokenPosition: Expected: \(expected) but found \(found?.debugDescription ?? "nil")", comment: "BlockParserError")
        }
    }
}

struct BlockParserResult {
    let conditionTokens: [Token]
    let mainTokens: [Token]
    let elseTokens: [Token]?
    let consumedTokens: Int
}

class BlockParser {
    private let tokens: [Token]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func getIfBlock(ifTokenIndex index: Int) throws -> BlockParserResult {
        guard let entryToken = self.tokens[safeIndex: index] else {
            throw BlockParserError.invalidTokenPosition(found: nil, expected: .ifStatement)
        }
        guard let entryToken = self.tokens[safeIndex: index], case .ifStatement = entryToken else {
            throw BlockParserError.invalidTokenPosition(found: entryToken, expected: .ifStatement)
        }
        var currentIndex = index + 1
        let conditionTokens  = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: currentIndex, tokens: self.tokens)
        currentIndex += conditionTokens.count + 2
        let mainTokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
        currentIndex += mainTokens.count + 2
        var elseTokens: [Token]? = nil
        
        print("else token: \(self.tokens[safeIndex: currentIndex])")
        if let elseToken = self.tokens[safeIndex: currentIndex], case .elseStatement = elseToken {
            currentIndex += 1
            elseTokens =  try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
            currentIndex += (elseTokens?.count ?? 0) + 2
        }
        let result = BlockParserResult(conditionTokens: conditionTokens, mainTokens: mainTokens, elseTokens: elseTokens, consumedTokens: currentIndex - index)
        return result
    }
    
}
