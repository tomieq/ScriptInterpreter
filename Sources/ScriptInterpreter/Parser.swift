//
//  Parser.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum ParserError: Error {
    case syntaxError(description: String)
    case internalError(description: String)
}

extension ParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("ParserError.syntaxError: \(info)", comment: "ParserError")
        case .internalError(let info):
            return NSLocalizedString("ParserError.internalError: \(info)", comment: "ParserError")
        }
    }
}

enum ParserExecResult: Equatable {
    case finished
    case `return`(Value?)
    case `break`
}

class Parser {
    private let externalFunctionRegistry: ExternalFunctionRegistry
    private let variableRegistry: VariableRegistry
    private let localFunctionRegistry: LocalFunctionRegistry
    private var currentIndex = 0
    
    private var tokens: [Token]
    
    init(tokens: [Token],
         externalFunctionRegistry: ExternalFunctionRegistry = ExternalFunctionRegistry(),
         localFunctionRegistry: LocalFunctionRegistry = LocalFunctionRegistry(),
         variableRegistry: VariableRegistry = VariableRegistry()) {
        self.externalFunctionRegistry = externalFunctionRegistry
        self.localFunctionRegistry = localFunctionRegistry
        self.variableRegistry = variableRegistry
        self.tokens = tokens
    }
    
    @discardableResult
    func execute() throws -> ParserExecResult {
        let variableParser = VariableParser(tokens: self.tokens)
        let functionParser = FunctionParser(tokens: self.tokens)
        

        while let token = self.tokens[safeIndex: self.currentIndex] {
            switch token {
            case .function(_), .functionWithArguments(_):
                _ = try self.invokeFunction()
            case .variableDefinition(_), .constantDefinition(_):
                let consumedTokens = try variableParser.parse(variableDefinitionIndex: self.currentIndex, into: self.variableRegistry)
                self.currentIndex += consumedTokens
            case .functionDefinition(_):
                let consumedTokens = try functionParser.parse(functionTokenIndex: self.currentIndex, into: self.localFunctionRegistry)
                self.currentIndex += consumedTokens
            case .ifStatement:
                let blockParser = BlockParser(tokens: self.tokens)
                let result = try blockParser.getIfBlock(ifTokenIndex: self.currentIndex)
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
                self.currentIndex += result.consumedTokens
            case .whileLoop:
                let blockParser = BlockParser(tokens: self.tokens)
                let result = try blockParser.getWhileBlock(whileTokenIndex: self.currentIndex)
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
                self.currentIndex += result.consumedTokens
            case .forLoop:
                let blockParser = BlockParser(tokens: self.tokens)
                let result = try blockParser.getForBlock(forTokenIndex: self.currentIndex)
                
                guard case .variableDefinition(_) = result.initialState[safeIndex: 0],
                      case .variable(let controlVariableName) = result.initialState[safeIndex: 1],
                      case .assign = result.initialState[safeIndex: 2],
                      case .intLiteral(let controlVariableInitialValue) = result.initialState[safeIndex: 3] else {
                    throw ParserError.syntaxError(description: "For loop error: initial state statement need to init variable")
                }
                // create for loop namespace and register initial value
                let forLoopVariableRegistry = VariableRegistry(topVariableRegistry: self.variableRegistry)
                try forLoopVariableRegistry.registerValue(name: controlVariableName, value: .integer(controlVariableInitialValue))
                // append statement 3 to be executed after each loop
                var body = result.body
                body.append(contentsOf: result.finalExpression)
                let conditionEvaluator = ConditionEvaluator(variableRegistry: forLoopVariableRegistry)
            forLoop: while (try conditionEvaluator.check(tokens: result.condition)) {
                    let result = try self.executeSubCode(tokens: body, variableRegistry: forLoopVariableRegistry)
                    switch result {
                    case .finished:
                        break
                    case .return(_):
                        return result
                    case .break:
                        break forLoop
                    }
                }
                self.currentIndex += result.consumedTokens
            case .blockOpen:
                // this is Swift-style separate namespace
                let blockTokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: self.currentIndex, tokens: self.tokens)
                let result = try self.executeSubCode(tokens: blockTokens, variableRegistry: self.variableRegistry)
                switch result {
                case .finished:
                    break
                case .return(_):
                    return result
                case .break:
                    break
                }
                self.currentIndex += blockTokens.count + 2
            case .variable(let name):
                try self.variableOperation(variableName: name)
            case .break:
                return .break
            case .return:
                self.currentIndex += 1
                if let returnedToken = self.tokens[safeIndex: self.currentIndex] {
                    if returnedToken.isLiteral || returnedToken.isVariable {
                        let returned = ParserUtils.token2Value(returnedToken, variableRegistry: self.variableRegistry)
                        return .return(returned)
                    }
                    if returnedToken.isFunction {
                        let result = try self.invokeFunction()
                        switch result {
                        case .finished, .break:
                            break
                        case .return(let optionalValue):
                            return .return(optionalValue)
                        }
                    }
                }
                return .return(nil)
            case .semicolon:
                self.currentIndex += 1
            default:
                throw ParserError.syntaxError(description: "Unexpected sign found: \(token)")
            }
        }
        return .finished
    }
    
    private func invokeFunction() throws -> ParserExecResult {
        guard let token = self.tokens[safeIndex: self.currentIndex] else {
            throw ParserError.internalError(description: "invokeFunction called on nil token")
        }
        switch token {
        case .function(let name):
            self.currentIndex += 1
            if let localFunction = self.localFunctionRegistry.getFunction(name: name) {
                let variableRegistry = VariableRegistry(topVariableRegistry: self.variableRegistry)
                return try self.executeSubCode(tokens: localFunction.body, variableRegistry: variableRegistry)
            } else {
                return .return(try self.externalFunctionRegistry.callFunction(name: name))
            }
            
        case .functionWithArguments(let name):
            self.currentIndex += 1
            let tokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: self.currentIndex, tokens: self.tokens)
            self.currentIndex += tokens.count + 2
            let argumentTokens = tokens.filter { $0 != .comma }
            let optionalArgumentValues = argumentTokens.map { ParserUtils.token2Value($0, variableRegistry: self.variableRegistry) }
            if optionalArgumentValues.contains(nil) {
                throw ParserError.syntaxError(description: "Passed invalid arguments: \(optionalArgumentValues) to function \(name)")
            }
            let argumentValues = optionalArgumentValues.compactMap{ $0 }
            if let localFunction = self.localFunctionRegistry.getFunction(name: name) {
                let variableRegistry = VariableRegistry(topVariableRegistry: self.variableRegistry)
                guard localFunction.argumentNames.count == argumentValues.count else {
                    throw ParserError.syntaxError(description: "Function \(name) expects arguments \(localFunction.argumentNames) but provided \(argumentValues)")
                }
                try localFunction.argumentNames.enumerated().forEach { (index, name) in try variableRegistry.registerValue(name: name, value: argumentValues[index]) }
                return try self.executeSubCode(tokens: localFunction.body, variableRegistry: variableRegistry)
            } else {
                return .return(try self.externalFunctionRegistry.callFunction(name: name, args: argumentValues))
            }
        default:
            throw ParserError.internalError(description: "invokeFunction called on \(token) token")
        }
    }
    
    private func variableOperation(variableName: String) throws {
        self.currentIndex += 1
        guard let nextToken = self.tokens[safeIndex: self.currentIndex] else {
            return
        }
        
        switch nextToken {
        case .assign:
            self.currentIndex += 1
            guard let valueToken = self.tokens[safeIndex: self.currentIndex] else {
                throw ParserError.syntaxError(description: "Missing right value for assign variable \(variableName)")
            }
            if valueToken.isLiteral || valueToken.isVariable {
                guard let value = ParserUtils.token2Value(valueToken, variableRegistry: self.variableRegistry) else {
                    throw ParserError.syntaxError(description: "Right value for assign variable \(variableName) should be either literal value or variable")
                }
                try self.variableRegistry.updateValue(name: variableName, value: value)
                self.currentIndex += 1
                return
            }
            if valueToken.isFunction {
                let result = try self.invokeFunction()
                switch result {
                case .finished, .break:
                    break
                case .return(let optionalValue):
                    if let value = optionalValue {
                        try self.variableRegistry.updateValue(name: variableName, value: value)
                        return
                    }
                }
                throw ParserError.syntaxError(description: "Could not assign value to variable `\(variableName)` - function did not return any value")
            }
            throw ParserError.syntaxError(description: "Invalid syntax after `\(variableName) =` - found \(valueToken)")
        case .increment:
            self.currentIndex += 1
            let variable = self.variableRegistry.getValue(name: variableName)
            guard case .integer(let intValue) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Increment operation can be applied only for integer type, but \(type) found")
            }
            try self.variableRegistry.updateValue(name: variableName, value: .integer(intValue + 1))
        case .decrement:
            self.currentIndex += 1
            let variable = self.variableRegistry.getValue(name: variableName)
            guard case .integer(let intValue) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Decrement operation can be applied only for integer type, but \(type) found")
            }
            try self.variableRegistry.updateValue(name: variableName, value: .integer(intValue - 1))
        default:
            break
        }
    }
    
    private func executeSubCode(tokens: [Token], variableRegistry topVariableRegistry: VariableRegistry) throws -> ParserExecResult {
        let variableRegistry = VariableRegistry(topVariableRegistry: topVariableRegistry)
        let localFunctionRegistry = LocalFunctionRegistry(topFunctionRegistry: self.localFunctionRegistry)
        let parser = Parser(tokens: tokens, externalFunctionRegistry: self.externalFunctionRegistry, localFunctionRegistry: localFunctionRegistry, variableRegistry: variableRegistry)
        return try parser.execute()
    }
}
