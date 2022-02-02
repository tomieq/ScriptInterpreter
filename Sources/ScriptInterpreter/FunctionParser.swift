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
        
        guard case .functionDefinition(let type) = token else {
            throw FunctionParserError.syntaxError(description: "Expected function definiotion token at index \(index)")
        }
        currentIndex += 1
        guard let functionNameToken = self.tokens[safeIndex: currentIndex] else {
            throw FunctionParserError.syntaxError(description: "Function name token not found at index \(index)")
        }
        var functionName = ""
        var body: [Token] = []
        
        switch functionNameToken {
        case .function(let name):
            functionName = name
            currentIndex += 1
            body = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
            currentIndex += body.count
        case .functionWithArguments(let name):
            functionName = name
        default:
            throw FunctionParserError.syntaxError(description: "After function definition function name is required, token index = \(index)")
        }
        
        let function = LocalFunction(name: functionName, argumentNames: [], body: body)
        functionRegistry.register(function)
        
        return currentIndex - index
    }
}
