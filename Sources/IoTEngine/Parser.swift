//
//  Parser.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum ParserError: Error {
    case syntaxError(description: String)
}

extension ParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("ParserError.syntaxError: \(info)", comment: "ParserError")
        }
    }
}

class Parser {
    private let functionRegistry: ExternalFunctionRegistry
    private let valueRegistry: ValueRegistry
    
    private var tokens: [Token]
    
    init(tokens: [Token], functionRegistry: ExternalFunctionRegistry = ExternalFunctionRegistry(), valueRegistry: ValueRegistry = ValueRegistry()) {
        self.functionRegistry = functionRegistry
        self.valueRegistry = valueRegistry
        self.tokens = tokens
    }
    
    func execute() throws {
        let valueParser = VariableParser(tokens: self.tokens)
        try valueParser.parse(into: self.valueRegistry)
        self.tokens = valueParser.leftTokens
        
        for (index, token) in self.tokens.enumerated() {
            switch token {
            case .function(let name):
                try self.functionRegistry.callFunction(name: name)
            case .functionWithArguments(let name):
                let tokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: index + 1, tokens: self.tokens).filter { $0 != .comma }
                try self.functionRegistry.callFunction(name: name, args: tokens.compactMap { ParserUtils.token2Value($0, valueRegistry: self.valueRegistry) })
                break
            default:
                break
            }
        }
    }
}
