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
        
        var index = 0
        while let token = self.tokens[safeIndex: index] {
            switch token {
            case .function(let name):
                try self.functionRegistry.callFunction(name: name)
            case .functionWithArguments(let name):
                let tokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: index + 1, tokens: self.tokens)
                index += tokens.count + 1
                let argumentTokens = tokens.filter { $0 != .comma }
                try self.functionRegistry.callFunction(name: name, args: argumentTokens.compactMap { ParserUtils.token2Value($0, valueRegistry: self.valueRegistry) })
                break
            case .ifStatement:
                let blockParser = BlockParser(tokens: self.tokens)
                let result = try blockParser.getIfBlock(ifTokenIndex: index)
                let conditionEvaluator = ConditionEvaluator(valueRegistry: self.valueRegistry)
                let shouldRunMainStatement = try conditionEvaluator.check(tokens: result.conditionTokens)
                if shouldRunMainStatement {
                    let valueRegistry = ValueRegistry(upperValueRegistry: self.valueRegistry)
                    let parser = Parser(tokens: result.mainTokens, functionRegistry: self.functionRegistry, valueRegistry: valueRegistry)
                    try parser.execute()
                } else if let elseTokens = result.elseTokens {
                    let valueRegistry = ValueRegistry(upperValueRegistry: self.valueRegistry)
                    let parser = Parser(tokens: elseTokens, functionRegistry: self.functionRegistry, valueRegistry: valueRegistry)
                    try parser.execute()
                }
                index += result.consumedTokens - 1
            case .variable(let name):
                index += try self.variableOperation(variableName: name, index: index)
            case .break:
                return
            default:
                break
            }
            index += 1
        }
    }
    
    private func variableOperation(variableName: String, index: Int) throws -> Int {
        guard let nextToken = self.tokens[safeIndex: index + 1] else {
            return 0
        }
        print("variableOperation:nextToken:\(nextToken)")
        switch nextToken {
        case .assign:
            guard let valueToken = self.tokens[safeIndex: index + 2], let value = ParserUtils.token2Value(valueToken, valueRegistry: self.valueRegistry) else {
                throw ParserError.syntaxError(description: "Right value for assign variable \(variableName) should be either literal value or variable")
            }
            try self.valueRegistry.updateValue(name: variableName, value: value)
            return 2
        case .increment:
            let variable = self.valueRegistry.getValue(name: variableName)
            guard case .integer(let intValue) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Increment operation can be applied only for integer type, but \(type) found")
            }
            try self.valueRegistry.updateValue(name: variableName, value: .integer(intValue + 1))
        case .decrement:
            let variable = self.valueRegistry.getValue(name: variableName)
            guard case .integer(let intValue) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Decrement operation can be applied only for integer type, but \(type) found")
            }
            try self.valueRegistry.updateValue(name: variableName, value: .integer(intValue - 1))
            break
        default:
            break
        }
        return 0
    }
}
