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

struct ForLoopParserResult {
    let initialState: [Token]
    let condition: [Token]
    let finalExpression: [Token]
    let body: [Token]
    let consumedTokens: Int
}

struct SwitchParserResult {
    let variable: [Token]
    let `default`: [Token]
    let cases: [Token: [Token]]
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
    
    func getForBlock(forTokenIndex index: Int) throws -> ForLoopParserResult {
        let result = try self.getBlock(tokenIndex: index, token: .forLoop)
        guard result.elseTokens == nil else {
            throw BlockParserError.syntaxError(info: "else statement is not allowed after for clause")
        }
        let statementTokens = result.conditionTokens.split(by: .semicolon)
        guard statementTokens.count == 3 else {
            throw BlockParserError.syntaxError(info: "For loop requires 3 statements: initial state, the condition and code that is executed after main block")
        }
        let initialState = statementTokens[0]
        let condition = statementTokens[1]
        let finalExpression = statementTokens[2]
        return ForLoopParserResult(initialState: initialState, condition: condition, finalExpression: finalExpression, body: result.mainTokens, consumedTokens: result.consumedTokens)
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
    
    func getSwitchBlock(switchTokenIndex index: Int) throws -> SwitchParserResult {
        guard let entryToken = self.tokens[safeIndex: index] else {
            throw BlockParserError.invalidTokenPosition(found: nil, expected: .switch)
        }
        guard let entryToken = self.tokens[safeIndex: index], case .switch = entryToken else {
            throw BlockParserError.invalidTokenPosition(found: entryToken, expected: .switch)
        }
        var currentIndex = index + 1
        guard let controlToken = self.tokens[safeIndex: currentIndex] else {
            throw BlockParserError.syntaxError(info: "Switch syntax required a variable as control statement")
        }
        var variableToken = [controlToken]
        if case .bracketOpen = variableToken.first {
            variableToken = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: currentIndex, tokens: self.tokens)
            currentIndex += 2
        }
        currentIndex += variableToken.count
        
        var defaultTokens: [Token] = []
        var cases: [Token: [Token]] = [:]
        
        let body = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
        let splitted = body.split(by: .case)
        for caseTokens in splitted {
            let parts = caseTokens.split(by: .default)

            guard let statements = parts[safeIndex: 0]?.split(by: .colon) else {
                continue
            }
            guard let keyToken = statements[safeIndex: 0]?.first, keyToken.isLiteral else {
                throw BlockParserError.syntaxError(info: "Case entry must be a literal")
            }
            cases[keyToken] = statements[safeIndex: 1] ?? []
            
            if let potentialDefaultTokens = parts[safeIndex: 1] {
                defaultTokens = potentialDefaultTokens.split(by: .colon)[safeIndex: 1] ?? []
            }
        }
        
        return SwitchParserResult(variable: variableToken, default: defaultTokens, cases: cases)
    }
}
