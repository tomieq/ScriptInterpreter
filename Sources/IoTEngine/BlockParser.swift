//
//  BlockParser.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation

enum BlockParserError: Error {
    case invalidTokenPosition(found: Token?, expected: Token)
    case syntaxError(info: String)
}

extension BlockParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTokenPosition(let found, let expected):
            return NSLocalizedString("BlockParserError.invalidTokenPosition: Expected: \(expected) but found \(found?.debugDescription ?? "nil")", comment: "BlockParserError")
        case .syntaxError(let info):
            return NSLocalizedString("BlockParserError.syntaxError: \(info)", comment: "BlockParserError")
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
        return try self.getBlock(tokenIndex: index, token: .ifStatement)
    }
    
    func getWhileBlock(whileTokenIndex index: Int) throws -> BlockParserResult {
        let result = try self.getBlock(tokenIndex: index, token: .whileLoop)
        guard result.elseTokens == nil else {
            throw BlockParserError.syntaxError(info: "else statement is not allowed after while clause")
        }
        return result
    }
    
    func getForBlock(forTokenIndex index: Int) throws -> BlockParserResult {
        let result = try self.getBlock(tokenIndex: index, token: .forLoop)
        guard result.elseTokens == nil else {
            throw BlockParserError.syntaxError(info: "else statement is not allowed after for clause")
        }
        return result
    }
    
    private func getBlock(tokenIndex index: Int, token: Token) throws -> BlockParserResult {
        guard let entryToken = self.tokens[safeIndex: index] else {
            throw BlockParserError.invalidTokenPosition(found: nil, expected: token)
        }
        guard let entryToken = self.tokens[safeIndex: index], case token = entryToken else {
            throw BlockParserError.invalidTokenPosition(found: entryToken, expected: token)
        }
        var currentIndex = index + 1
        let conditionTokens  = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: currentIndex, tokens: self.tokens)
        print("ConditionTokens[\(currentIndex)...]:\(conditionTokens)")
        currentIndex += conditionTokens.count + 2
        let mainTokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
        currentIndex += mainTokens.count + 2
        var elseTokens: [Token]? = nil

        if let elseToken = self.tokens[safeIndex: currentIndex], case .elseStatement = elseToken {
            currentIndex += 1
            elseTokens =  try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
            currentIndex += (elseTokens?.count ?? 0) + 2
        }
        let result = BlockParserResult(conditionTokens: conditionTokens, mainTokens: mainTokens, elseTokens: elseTokens, consumedTokens: currentIndex - index)
        return result
    }
}
