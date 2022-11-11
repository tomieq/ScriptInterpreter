//
//  ArithmeticCalculator.swift
//
//
//  Created by Tomasz KUCHARSKI on 10/11/2022.
//

import Foundation

enum ArithmeticCalculatorError: Error {
    case runtimeError(description: String)
    case syntaxError(description: String)
}

extension ArithmeticCalculatorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .runtimeError(let info):
            return NSLocalizedString("ArithmeticCalculatorError.runtimeError: \(info)", comment: "ArithmeticCalculatorError")
        case .syntaxError(let info):
            return NSLocalizedString("ArithmeticCalculatorError.syntaxError: \(info)", comment: "ArithmeticCalculatorError")
        }
    }
}

struct ArithmeticCalculatorResult {
    let value: Value?
    let consumedTokens: Int
}

class ArithmeticCalculator {
    private let logTag = "🦃 ArithmeticCalculator"
    let tokens: [Token]
    // we need all the registers, because calculator is capable of calling functions and resolving variables
    let registerSet: RegisterSet

    init(tokens: [Token], registerSet: RegisterSet) {
        self.tokens = tokens
        self.registerSet = registerSet
    }

    func calculateValue(startIndex: Int) throws -> ArithmeticCalculatorResult {
        var currentIndex = startIndex
        guard self.tokens[safeIndex: currentIndex].notNil else {
            throw ArithmeticCalculatorError.runtimeError(description: "Token not found at index \(startIndex)")
        }
        Logger.v(self.logTag, "Calculating value starting from token \(self.tokens[startIndex])")
        var selectedTokens: [Token] = []
        var useBooleanCalculator = false
        var previousTokenIsOperator = true

        loop: while let token = self.tokens[safeIndex: currentIndex] {
            switch token {
            case .stringLiteral, .intLiteral, .floatLiteral:
                guard previousTokenIsOperator else {
                    break loop
                }
                previousTokenIsOperator = false
                selectedTokens.append(token)
                currentIndex += 1
            case .add, .subtract:
                previousTokenIsOperator = true
                selectedTokens.append(token)
                currentIndex += 1
            case .boolLiteral, .andOperator, .orOperator, .equal, .notEqual, .less, .lessOrEqual, .greater, .greaterOrEqual:
                selectedTokens.append(token)
                useBooleanCalculator = true
                currentIndex += 1
                previousTokenIsOperator = true
            case .variable(let variableName):
                guard previousTokenIsOperator else {
                    break loop
                }
                previousTokenIsOperator = false
                guard let variableType = self.registerSet.variableRegistry.getVariable(name: variableName) else {
                    throw ArithmeticCalculatorError.syntaxError(description: "Could not find variable \(variableName)")
                }
                switch variableType {
                case .primitive(let variable):
                    selectedTokens.append(variable.literalToken)
                    currentIndex += 1
                case .class(let objectTypeName, let variableRegistry):
                    guard let objectType = self.registerSet.objectTypeRegistry.getObjectType(objectTypeName) else {
                        throw ArithmeticCalculatorError.syntaxError(description: "Could not find objectType \(objectTypeName)")
                    }
                    currentIndex += 1
                    guard let methodToken = self.tokens[safeIndex: currentIndex] else {
                        throw ArithmeticCalculatorError.syntaxError(description: "Invalid syntax. After class instance name a method name is required! \(variableName):\(objectTypeName)")
                    }
                    switch methodToken {
                    case .method(let methodName):
                        guard let method = objectType.methodsRegistry.getFunction(name: methodName) else {
                            throw ArithmeticCalculatorError.syntaxError(description: "Uknown method \(methodName) on objectType \(variableName):\(objectTypeName)")
                        }
                        Logger.v(self.logTag, "invoke method \(methodName)() on \(variableName):\(objectTypeName)")
                        Logger.v(self.logTag, "creating variableRegistry for method context")
                        let methodVariableRegistry = VariableRegistry(topVariableRegistry: variableRegistry)
                        let calculatedToken = try self.executeTokens(tokens: method.body, variableRegistry: methodVariableRegistry).literalToken
                        selectedTokens.append(calculatedToken)
                        currentIndex += 1
                    case .methodWithArguments(let methodName):
                        currentIndex += 1
                        guard let method = objectType.methodsRegistry.getFunction(name: methodName) else {
                            throw ArithmeticCalculatorError.syntaxError(description: "Uknown method \(methodName) on objectType \(variableName):\(objectTypeName)")
                        }
                        let argumentParser = FunctionArgumentParser(tokens: self.tokens, registerSet: self.registerSet)
                        let parserResult = try argumentParser.getArgumentValues(index: currentIndex)
                        currentIndex += parserResult.consumedTokens
                        let values = parserResult.values
                        Logger.v(self.logTag, "invoke method \(methodName)(\(values.map{ $0.asTypeValue }.joined(separator: ", "))) on \(variableName):\(objectTypeName)")
                        Logger.v(self.logTag, "creating variableRegistry for method context")
                        let methodVariableRegistry = VariableRegistry(topVariableRegistry: variableRegistry)
                        // validate function signature - whether number of arguments passed to func matches function definition
                        guard method.argumentNames.count == values.count else {
                            throw ParserError.syntaxError(description: "Function \(methodName) expects arguments \(method.argumentNames) but provided \(values)")
                        }
                        // init variable registry for functions' memory space
                        try method.argumentNames.enumerated().forEach { (index, name) in
                            try methodVariableRegistry.registerVariable(name: name, variable: .primitive(values[index]))
                        }
                        let calculatedToken = try self.executeTokens(tokens: method.body, variableRegistry: methodVariableRegistry).literalToken
                        selectedTokens.append(calculatedToken)
                    case .attribute(let attributeName):
                        guard let attribute = variableRegistry.getVariable(name: attributeName) else {
                            throw ArithmeticCalculatorError.syntaxError(description: "Uknown attribute \(attributeName) on objectType \(variableName):\(objectTypeName)")
                        }
                        switch attribute {
                        case .primitive(let value):
                            selectedTokens.append(value.literalToken)
                        default:
                            throw ArithmeticCalculatorError.syntaxError(description: "Attribute \(attributeName) on objectType \(variableName):\(objectTypeName) is not simple value!")
                        }
                        currentIndex += 1
                    default:
                        throw ArithmeticCalculatorError.syntaxError(description: "Invalid syntax. After class instance name a method name is required but found \(methodToken) \(variableName):\(objectTypeName)")
                    }
                    break loop
                }
            case .function(let functionName):
                guard previousTokenIsOperator else {
                    break loop
                }
                previousTokenIsOperator = false
                if let localFunction = self.registerSet.localFunctionRegistry.getFunction(name: functionName) {
                    Logger.v(self.logTag, "invoke local function \(functionName)()")
                    let variableRegistry = VariableRegistry(topVariableRegistry: self.registerSet.variableRegistry)
                    let calculatedToken = try self.executeTokens(tokens: localFunction.body, variableRegistry: variableRegistry).literalToken
                    selectedTokens.append(calculatedToken)
                    currentIndex += 1
                } else {
                    guard let calculatedToken = try self.registerSet.externalFunctionRegistry.callFunction(name: functionName)?.literalToken else {
                        throw ArithmeticCalculatorError.syntaxError(description: "External function \(functionName) did not return any value")
                    }
                    selectedTokens.append(calculatedToken)
                    currentIndex += 1
                }
            case .functionWithArguments(let functionName):
                guard previousTokenIsOperator else {
                    break loop
                }
                previousTokenIsOperator = false
                currentIndex += 1
                let argumentParser = FunctionArgumentParser(tokens: self.tokens, registerSet: self.registerSet)
                let parserResult = try argumentParser.getArgumentValues(index: currentIndex)
                currentIndex += parserResult.consumedTokens
                let values = parserResult.values
                if let localFunction = self.registerSet.localFunctionRegistry.getFunction(name: functionName) {
                    Logger.v(self.logTag, "invoke local function \(functionName)(\(values.map{ $0.asTypeValue }.joined(separator: ", ")))")
                    let variableRegistry = VariableRegistry(topVariableRegistry: self.registerSet.variableRegistry)
                    // validate function signature - whether number of arguments passed to func matches function definition
                    guard localFunction.argumentNames.count == values.count else {
                        throw ParserError.syntaxError(description: "Function \(functionName) expects arguments \(localFunction.argumentNames) but provided \(values)")
                    }
                    // init variable registry for functions' memory space
                    try localFunction.argumentNames.enumerated().forEach { (index, name) in
                        try variableRegistry.registerVariable(name: name, variable: .primitive(values[index]))
                    }
                    let calculatedToken = try self.executeTokens(tokens: localFunction.body, variableRegistry: variableRegistry).literalToken
                    selectedTokens.append(calculatedToken)
                } else {
                    guard let calculatedToken = try self.registerSet.externalFunctionRegistry.callFunction(name: functionName, args: values)?.literalToken else {
                        throw ArithmeticCalculatorError.syntaxError(description: "External function \(functionName) did not return any value")
                    }
                    selectedTokens.append(calculatedToken)
                }
            default:
                break loop
            }
        }
        guard let firstToken = selectedTokens[safeIndex: 0] else {
            throw ArithmeticCalculatorError.syntaxError(description: "Invalid syntax. No token found for ArithmeticCalculator")
        }
        let value: Value?
        if useBooleanCalculator {
            let conditionEvaluator = ConditionEvaluator(variableRegistry: self.registerSet.variableRegistry)
            value = .bool(try conditionEvaluator.check(tokens: selectedTokens))
        } else {
            switch firstToken {
            case .intLiteral:
                value = try self.calculateIntegerOperations(selectedTokens: selectedTokens)
            case .floatLiteral:
                value = try self.calculateFloatOperations(selectedTokens: selectedTokens)
            case .stringLiteral:
                value = ParserUtils.token2Value(try self.concatenateStrings(selectedTokens: selectedTokens).literalToken,
                                                variableRegistry: self.registerSet.variableRegistry)
            case .boolLiteral:
                let conditionEvaluator = ConditionEvaluator(variableRegistry: self.registerSet.variableRegistry)
                value = .bool(try conditionEvaluator.check(tokens: selectedTokens))
            default:
                throw ArithmeticCalculatorError.syntaxError(description: "Invalid token for ArithmeticCalculator: \(firstToken)")
            }
        }
        //let values = selectedTokens.compactMap { ParserUtils.token2Value($0, variableRegistry: self.variableRegistry) }
        return ArithmeticCalculatorResult(value: value, consumedTokens: currentIndex - startIndex)
    }

    private func calculateIntegerOperations(selectedTokens: [Token]) throws -> Value {
        enum Operation {
            case add
            case subtract
        }
        var total = 0
        var operation: Operation?
        for token in selectedTokens {
            switch token {
            case .intLiteral(let number):
                if let operation = operation {
                    switch operation {
                    case .add:
                        total += number
                    case .subtract:
                        total -= number
                    }
                } else {
                    total = number
                }
            case .add:
                operation = .add
            case .subtract:
                operation = .subtract
            default:
                throw ArithmeticCalculatorError.syntaxError(description: "Invalid sign \(token) found in ArithmeticCalculator:integerLogic")
            }
        }
        return .integer(total)
    }

    private func calculateFloatOperations(selectedTokens: [Token]) throws -> Value {
        enum Operation {
            case add
            case subtract
        }
        var total: Float = 0
        var operation: Operation?
        for token in selectedTokens {
            switch token {
            case .floatLiteral(let number):
                if let operation = operation {
                    switch operation {
                    case .add:
                        total += number
                    case .subtract:
                        total -= number
                    }
                } else {
                    total = number
                }
            case .add:
                operation = .add
            case .subtract:
                operation = .subtract
            default:
                throw ArithmeticCalculatorError.syntaxError(description: "Invalid sign \(token) found in ArithmeticCalculator:integerLogic")
            }
        }
        return .float(round(total * 100) / 100.0)
    }

    private func concatenateStrings(selectedTokens: [Token]) throws -> Value {
        var result = ""
        for token in selectedTokens {
            switch token {
            case .stringLiteral(let txt):
                result.append(txt)
            case .add:
                continue
            default:
                throw ArithmeticCalculatorError.syntaxError(description: "Invalid sign \(token) found in ArithmeticCalculator:integerLogic")
            }
        }
        return .string(result)
    }

    private func executeTokens(tokens: [Token], variableRegistry: VariableRegistry) throws -> Value {
        let localFunctionRegistry = LocalFunctionRegistry(topFunctionRegistry: self.registerSet.localFunctionRegistry)
        let parser = Parser(tokens: tokens,
                            externalFunctionRegistry: self.registerSet.externalFunctionRegistry,
                            localFunctionRegistry: localFunctionRegistry,
                            variableRegistry: variableRegistry)
        let result = try parser.execute()
        switch result {
        case .return(let value):
            guard let value = value else {
                throw ArithmeticCalculatorError.syntaxError(description: "Function did not return any value ArithmeticCalculator:executeTokens")
            }
            return value
        default:
            throw ArithmeticCalculatorError.syntaxError(description: "Function did not return any value ArithmeticCalculator:executeTokens")
        }
    }
}
