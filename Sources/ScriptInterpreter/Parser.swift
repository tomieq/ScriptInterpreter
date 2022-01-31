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

enum ParserExecResult: Equatable {
    case finished
    case `return`(Value?)
    case `break`
}

class Parser {
    private let functionRegistry: ExternalFunctionRegistry
    private let variableRegistry: VariableRegistry
    
    private var tokens: [Token]
    
    init(tokens: [Token], functionRegistry: ExternalFunctionRegistry = ExternalFunctionRegistry(), variableRegistry: VariableRegistry = VariableRegistry()) {
        self.functionRegistry = functionRegistry
        self.variableRegistry = variableRegistry
        self.tokens = tokens
    }
    
    @discardableResult
    func execute() throws -> ParserExecResult {
        let variableParser = VariableParser(tokens: self.tokens)
        
        var index = 0
        while let token = self.tokens[safeIndex: index] {
            switch token {
            case .function(let name):
                try self.functionRegistry.callFunction(name: name)
                index += 1
            case .functionWithArguments(let name):
                let tokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: index + 1, tokens: self.tokens)
                index += tokens.count + 3
                let argumentTokens = tokens.filter { $0 != .comma }
                try self.functionRegistry.callFunction(name: name, args: argumentTokens.compactMap { ParserUtils.token2Value($0, variableRegistry: self.variableRegistry) })
                break
            case .variableDefinition(_), .constantDefinition(_):
                let consumedTokens = try variableParser.parse(variableDefinitionIndex: index, into: self.variableRegistry)
                index += consumedTokens
            case .ifStatement:
                let blockParser = BlockParser(tokens: self.tokens)
                let result = try blockParser.getIfBlock(ifTokenIndex: index)
                let conditionEvaluator = ConditionEvaluator(variableRegistry: self.variableRegistry)
                let shouldRunMainStatement = try conditionEvaluator.check(tokens: result.conditionTokens)
                if shouldRunMainStatement {
                    let result = try self.executeSubCode(tokens: result.mainTokens, variableRegistry: self.variableRegistry)
                    switch result {
                    case .finished:
                        break
                    case .break, .return(_):
                        return result
                    }
                } else if let elseTokens = result.elseTokens {
                    let result = try self.executeSubCode(tokens: elseTokens, variableRegistry: self.variableRegistry)
                    switch result {
                    case .finished:
                        break
                    case .break, .return(_):
                        return result
                    }
                }
                index += result.consumedTokens
            case .whileLoop:
                let blockParser = BlockParser(tokens: self.tokens)
                let result = try blockParser.getWhileBlock(whileTokenIndex: index)
                let conditionEvaluator = ConditionEvaluator(variableRegistry: self.variableRegistry)
                whileLoop: while (try conditionEvaluator.check(tokens: result.conditionTokens)) {
                    let result = try self.executeSubCode(tokens: result.mainTokens, variableRegistry: self.variableRegistry)
                    switch result {
                    case .finished:
                        break
                    case .return(_):
                        return result
                    case .break:
                        break whileLoop
                    }
                }
                index += result.consumedTokens
            case .forLoop:
                let blockParser = BlockParser(tokens: self.tokens)
                let result = try blockParser.getForBlock(forTokenIndex: index)
                let forLoopControlTokens = result.conditionTokens.split(by: .semicolon)
                guard forLoopControlTokens.count == 3 else {
                    throw ParserError.syntaxError(description: "For loop requires 3 statements: initial state, the condition and code that is executed after main block")
                }
                guard case .variableDefinition(_) = forLoopControlTokens[0][safeIndex: 0],
                      case .variable(let controlVariableName) = forLoopControlTokens[0][safeIndex: 1],
                      case .assign = forLoopControlTokens[0][safeIndex: 2],
                      case .intLiteral(let controlVariableInitialValue) = forLoopControlTokens[0][safeIndex: 3] else {
                    throw ParserError.syntaxError(description: "For loop error: initial state statement need to init variable")
                }
                // create for loop namespace and register initial value
                let forLoopVariableRegistry = VariableRegistry(topVariableRegistry: self.variableRegistry)
                try forLoopVariableRegistry.registerValue(name: controlVariableName, value: .integer(controlVariableInitialValue))
                // append statement 3 to be executed after each loop
                var forLoopTokens = result.mainTokens
                forLoopTokens.append(contentsOf: forLoopControlTokens[2])
                let conditionEvaluator = ConditionEvaluator(variableRegistry: forLoopVariableRegistry)
                forLoop: while (try conditionEvaluator.check(tokens: forLoopControlTokens[1])) {
                    let result = try self.executeSubCode(tokens: forLoopTokens, variableRegistry: forLoopVariableRegistry)
                    switch result {
                    case .finished:
                        break
                    case .return(_):
                        return result
                    case .break:
                        break forLoop
                    }
                }
                index += result.consumedTokens
            case .blockOpen:
                // this is Swift-style separate namespace
                let blockTokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: index, tokens: self.tokens)
                let result = try self.executeSubCode(tokens: blockTokens, variableRegistry: self.variableRegistry)
                switch result {
                case .finished:
                    break
                case .return(_):
                    return result
                case .break:
                    break
                }
                index += blockTokens.count + 2
            case .variable(let name):
                index += try self.variableOperation(variableName: name, index: index) + 1
            case .break:
                return .break
            case .return:
                if let returnedToken = self.tokens[safeIndex: index + 1],
                   let returned = ParserUtils.token2Value(returnedToken, variableRegistry: self.variableRegistry) {
                    return .return(returned)
                }
                return .return(nil)
            case .semicolon:
                index += 1
            default:
                throw ParserError.syntaxError(description: "Unexpected sign found: \(token)")
            }
        }
        return .finished
    }
    
    private func variableOperation(variableName: String, index: Int) throws -> Int {
        guard let nextToken = self.tokens[safeIndex: index + 1] else {
            return 0
        }
        switch nextToken {
        case .assign:
            guard let valueToken = self.tokens[safeIndex: index + 2], let value = ParserUtils.token2Value(valueToken, variableRegistry: self.variableRegistry) else {
                throw ParserError.syntaxError(description: "Right value for assign variable \(variableName) should be either literal value or variable")
            }
            try self.variableRegistry.updateValue(name: variableName, value: value)
            return 2
        case .increment:
            let variable = self.variableRegistry.getValue(name: variableName)
            guard case .integer(let intValue) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Increment operation can be applied only for integer type, but \(type) found")
            }
            try self.variableRegistry.updateValue(name: variableName, value: .integer(intValue + 1))
            return 1
        case .decrement:
            let variable = self.variableRegistry.getValue(name: variableName)
            guard case .integer(let intValue) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Decrement operation can be applied only for integer type, but \(type) found")
            }
            try self.variableRegistry.updateValue(name: variableName, value: .integer(intValue - 1))
            return 1
        default:
            break
        }
        return 0
    }
    
    private func executeSubCode(tokens: [Token], variableRegistry topVariableRegistry: VariableRegistry) throws -> ParserExecResult {
        let variableRegistry = VariableRegistry(topVariableRegistry: topVariableRegistry)
        let parser = Parser(tokens: tokens, functionRegistry: self.functionRegistry, variableRegistry: variableRegistry)
        return try parser.execute()
    }
}
