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
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse(variableDefinitionIndex index: Int, into variableRegistry: VariableRegistry) throws -> Int {

        
        guard let token = self.tokens[safeIndex: index] else {
            throw VariableParserError.syntaxError(description: "Token not found at index \(index)")
        }
        var usedTokens = 1
        switch token {
        case .variableDefinition(let definitionType):
            while let data = try self.initVariable(variableTokenIndex: index + 1, definitionType: definitionType, variableRegistry: variableRegistry, registerFuncion: variableRegistry.registerValue) {
                
                usedTokens += data.usedTokens
                if !data.shouldParseFurther {
                    break
                }
            }
        case .constantDefinition(let definitionType):
            while let data = try self.initVariable(variableTokenIndex: index + 1, definitionType: definitionType, variableRegistry: variableRegistry, registerFuncion: variableRegistry.registerConstant) {
                
                usedTokens += data.usedTokens
                if !data.shouldParseFurther {
                    break
                }
            }
        default:
            throw VariableParserError.syntaxError(description: "Inproper token found at index \(index): \(token)")
        }
        return usedTokens
    }
    
    private func initVariable(variableTokenIndex pos: Int, definitionType: String, variableRegistry: VariableRegistry, registerFuncion: (String, Value?) -> ()) throws -> (shouldParseFurther: Bool, usedTokens: Int)? {
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
            registerFuncion(name, value)
            usedTokens += 2
        } else {
            registerFuncion(name, nil)
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
