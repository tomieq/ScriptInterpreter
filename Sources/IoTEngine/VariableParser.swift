//
//  VariableParser.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum VariableParserError: Error {
    case syntaxError(description: String)
}

extension VariableParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("VariableParserError.syntaxError: \(info)", comment: "VariableParserError")
        }
    }
}

class VariableParser {
    private let tokens: [Token]
    private var consumedTokenIndices: [Int]
    
    var leftTokens: [Token] {
        return self.tokens.enumerated().filter { (index, token) in !self.consumedTokenIndices.contains(index) }.map{ $0.element }
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
        self.consumedTokenIndices = []
    }
    
    func parse(into variableRegistry: VariableRegistry) throws {
        var index = 0
        while let token = self.tokens[safeIndex: index] {
            
            switch token {
            case .variableDefinition(let definitionType):
                while let data = try self.initVariable(variableTokenIndex: index + 1, definitionType: definitionType, variableRegistry: variableRegistry) {
                    
                    let usedTokenRange = (index...(index + data.usedTokens))
                    self.consumedTokenIndices.append(contentsOf: usedTokenRange)
                    
                    index += data.usedTokens
                    if !data.shouldParseFurther {
                        break
                    }
                }
            case .blockOpen:
                let tokensInBlock = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: index, tokens: self.tokens)
                index += tokensInBlock.count + 1
            default:
                break
            }
            index += 1
        }
    }
    
    private func initVariable(variableTokenIndex pos: Int, definitionType: String, variableRegistry: VariableRegistry) throws -> (shouldParseFurther: Bool, usedTokens: Int)? {
        guard case .variable(let name) = self.tokens[safeIndex: pos] else {
            throw VariableParserError.syntaxError(description: "No variable name found after keyword \(definitionType) usage!")
        }
        var usedTokens = 1
        var shouldParseFurther = false
        if let nextToken = self.tokens[safeIndex: pos + 1], case .assign = nextToken {
            
            guard let valueToken = self.tokens[safeIndex: pos + 2] else {
                throw VariableParserError.syntaxError(description: "Value not found for assigning variable \(name)")
            }
            guard let value = ParserUtils.token2Value(valueToken, variableRegistry: variableRegistry) else {
                throw VariableParserError.syntaxError(description: "Invalid value assigned to variable \(name) [\(valueToken)]")
            }
            variableRegistry.registerValue(name: name, value: value)
            usedTokens += 2
        } else {
            variableRegistry.registerValue(name: name, value: nil)
        }
        let lastToken = self.tokens[safeIndex: pos + usedTokens]
        if case .comma = lastToken {
            shouldParseFurther = true
            usedTokens += 1
        }
        if case .semicolon = lastToken {
            usedTokens += 1
        }
        return (shouldParseFurther, usedTokens)
    }
}
