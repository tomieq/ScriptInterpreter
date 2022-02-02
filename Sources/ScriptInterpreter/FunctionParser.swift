//
//  FunctionParser.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation

enum FunctionParserError: Error {
    case syntaxError(description: String)
}

extension FunctionParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("VariableParserError.syntaxError: \(info)", comment: "VariableParserError")
        }
    }
}

class FunctionParser {
    private let tokens: [Token]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse(functionTokenIndex index: Int, into functionRegistry: LocalFunctionRegistry) throws -> Int {
        var currentIndex = index
        guard let token = self.tokens[safeIndex: currentIndex] else {
            throw FunctionParserError.syntaxError(description: "Token not found at index \(index)")
        }
        
        guard case .functionDefinition(_) = token else {
            throw FunctionParserError.syntaxError(description: "Expected function definiotion token at index \(index)")
        }
        currentIndex += 1
        guard let functionNameToken = self.tokens[safeIndex: currentIndex] else {
            throw FunctionParserError.syntaxError(description: "Function name token not found at index \(index)")
        }
        var functionName = ""
        var argumentNames: [String] = []
        
        switch functionNameToken {
        case .function(let name):
            functionName = name
            currentIndex += 1
        case .functionWithArguments(let name):
            currentIndex += 1
            functionName = name
            
            let argumetTokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: currentIndex, tokens: self.tokens)
            currentIndex += argumetTokens.count + 2
            for argumentArray in argumetTokens.split(by: .comma) {
                guard argumentArray.count == 1 else {
                    throw FunctionParserError.syntaxError(description: "Invalid argument names in function \(functionName)")
                }
                guard case .variable(let variableName) = argumentArray.first! else {
                    throw FunctionParserError.syntaxError(description: "Function definition \(functionName) arguments should be names, but found \(argumentArray.first!)")
                }
                argumentNames.append(variableName)
            }
        default:
            throw FunctionParserError.syntaxError(description: "After function definition function name is required, token index = \(index)")
        }
        let body = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
        currentIndex += body.count
        let function = LocalFunction(name: functionName, argumentNames: argumentNames, body: body)
        functionRegistry.register(function)
        
        return currentIndex - index
    }
    
    func validateToken(expected: Token, index: Int) throws {
        guard let current = self.tokens[safeIndex: index] else {
            throw FunctionParserError.syntaxError(description: "Expected token \(expected) but found nil")
        }
        guard expected == current else {
            throw FunctionParserError.syntaxError(description: "Expected token \(expected) but found \(current)")
        }
    }
}
