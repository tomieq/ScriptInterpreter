//
//  Parser.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

class Parser {
    private let lexicalAnalizer: LexicalAnalyzer
    private let functionRegistry: FunctionRegistry
    private let valueRegistry: ValueRegistry
    
    init(lexicalAnalizer: LexicalAnalyzer, functionRegistry: FunctionRegistry, valueRegistry: ValueRegistry) {
        self.lexicalAnalizer = lexicalAnalizer
        self.functionRegistry = functionRegistry
        self.valueRegistry = valueRegistry
    }
    
    func execute() throws {
        for (index, token) in self.lexicalAnalizer.lexer.tokens.enumerated() {
            switch token {
            case .function(let name):
                try self.functionRegistry.callFunction(name: name)
            case .functionWithArguments(let name):
                let tokens = self.lexicalAnalizer.getTokensBetweenBrackets(indexOfOpeningBracket: index + 1)
                try self.functionRegistry.callFunction(name: name, args: tokens.compactMap { self.token2Value($0) })
                break
            default:
                break
            }
        }
    }
    
    private func token2Value(_ token: Token) -> Value? {
        switch token {
        case .intLiteral(let value):
            return .integer(value)
        case .stringLiteral(let value):
            return .string(value)
        case .boolLiteral(let value):
            return .bool(value)
        case .floatLiteral(let value):
            return .float(value)
        default:
            return nil
        }
    }
}
