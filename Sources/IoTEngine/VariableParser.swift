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

class VariableParser {
    let tokens: [Token]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse(into valueRegistry: ValueRegistry) throws {
        for (index, token) in self.tokens.enumerated() {
            switch token {
            case .variableDefinition(let definitionType):
                var tokenIndex = index + 1
                while let consumedTokens = try self.initVariable(variableTokenIndex: tokenIndex, definitionType: definitionType, valueRegistry: valueRegistry) {
                    tokenIndex += consumedTokens
                }
            default:
                break
            }
        }
    }
    
    private func initVariable(variableTokenIndex pos: Int, definitionType: String, valueRegistry: ValueRegistry) throws -> Int? {
        guard case .variable(let name) = self.tokens[safeIndex: pos] else {
            throw VariableParserError.syntaxError(description: "No variable name found after keyword \(definitionType) usage!")
        }
        var usedTokens = 1
        if let nextToken = self.tokens[safeIndex: pos + 1], case .assign = nextToken {
            
            guard let valueToken = self.tokens[safeIndex: pos + 2] else {
                throw VariableParserError.syntaxError(description: "Value not found for assigning variable \(name)")
            }
            guard let value = ParserUtils.token2Value(valueToken, valueRegistry: valueRegistry) else {
                throw VariableParserError.syntaxError(description: "Invalid value assigned to variable \(name) [\(valueToken)]")
            }
            valueRegistry.registerValue(name: name, value: value)
            usedTokens += 2
        } else {
            valueRegistry.registerValue(name: name, value: nil)
        }
        if let lastToken = self.tokens[safeIndex: pos + usedTokens], case .comma = lastToken {
            return usedTokens + 1
        }
        return nil
    }
}
