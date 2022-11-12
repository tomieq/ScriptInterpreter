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
    case aborted(description: String)
}

extension ParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("ParserError.syntaxError: \(info)", comment: "ParserError")
        case .internalError(let info):
            return NSLocalizedString("ParserError.internalError: \(info)", comment: "ParserError")
        case .aborted(let info):
            return NSLocalizedString("ParserError.aborted: \(info)", comment: "ParserError")
        }
    }
}

enum ParserExecResult: Equatable {
    case finished
    case `return`(Value?)
    case `break`
}

enum ParserState {
    case idle
    case working
    case finished
    case aborted(String)
}

class Parser {
    private let logTag = "🐫 Parser"
    private let id = "0x".appendingRandomHexDigits(length: 4)
    private let externalFunctionRegistry: ExternalFunctionRegistry
    private let variableRegistry: VariableRegistry
    private let localFunctionRegistry: LocalFunctionRegistry
    private let objectTypeRegistry: ObjectTypeRegistry
    private let registerSet: RegisterSet
    private var currentIndex = 0

    private var state = ParserState.idle
    private var tokens: [Token]
    private var deferredTokens: [[Token]] = []

    init(tokens: [Token],
         externalFunctionRegistry: ExternalFunctionRegistry = ExternalFunctionRegistry(),
         localFunctionRegistry: LocalFunctionRegistry = LocalFunctionRegistry(),
         variableRegistry: VariableRegistry = VariableRegistry()) {
        Logger.v(self.logTag, "new parserID: \(self.id) with tokens: \(tokens.map{ $0.debugDescription }.joined(separator: " "))")
        self.externalFunctionRegistry = externalFunctionRegistry
        self.localFunctionRegistry = localFunctionRegistry
        self.variableRegistry = variableRegistry
        self.objectTypeRegistry = ObjectTypeRegistry()
        self.tokens = tokens
        self.registerSet = RegisterSet(variableRegistry: self.variableRegistry,
                                       localFunctionRegistry: self.localFunctionRegistry,
                                       externalFunctionRegistry: self.externalFunctionRegistry,
                                       objectTypeRegistry: self.objectTypeRegistry)
    }

    @discardableResult
    func execute() throws -> ParserExecResult {
        self.state = .working
        let variableParser = VariableParser(tokens: self.tokens, registerSet: self.registerSet, parser: self)
        let functionParser = FunctionParser(tokens: self.tokens)
        let blockParser = BlockParser(tokens: self.tokens)
        let objectTypeParser = ObjectTypeParser(tokens: self.tokens, registerSet: self.registerSet)

        // go through every token
        while let token = self.tokens[safeIndex: self.currentIndex] {
            if case .aborted(let reason) = self.state {
                Logger.v(self.logTag, "Program execution aborted with reason: \(reason)")
                throw ParserError.aborted(description: reason)
            }
            switch token {
            case .function(_), .functionWithArguments(_):
                _ = try self.invokeFunction()
            case .variableDefinition(_), .constantDefinition(_):
                let consumedTokens = try variableParser.parse(variableDefinitionIndex: self.currentIndex)
                self.currentIndex += consumedTokens
            case .functionDefinition(_):
                let consumedTokens = try functionParser.parse(functionTokenIndex: self.currentIndex, into: self.localFunctionRegistry)
                self.currentIndex += consumedTokens
            case .class(_):
                let consumedTokens = try objectTypeParser.parse(objectTypeDefinitionIndex: self.currentIndex, into: self.objectTypeRegistry)
                self.currentIndex += consumedTokens
            case .ifStatement:
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
                let result = try blockParser.getWhileBlock(whileTokenIndex: self.currentIndex)
                let conditionEvaluator = ConditionEvaluator(variableRegistry: self.variableRegistry)
                whileLoop: while (try conditionEvaluator.check(tokens: result.conditionTokens)) {
                    if case .aborted(let reason) = self.state { throw ParserError.aborted(description: reason) }
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
                let result = try blockParser.getForBlock(forTokenIndex: self.currentIndex)

                guard case .variableDefinition(_) = result.initialState[safeIndex: 0],
                      case .variable(let controlVariableName) = result.initialState[safeIndex: 1],
                      case .assign = result.initialState[safeIndex: 2],
                      case .intLiteral(let controlVariableInitialValue) = result.initialState[safeIndex: 3] else {
                    throw ParserError.syntaxError(description: "For loop error: initial state statement need to init variable")
                }
                // create for loop namespace and register initial value
                let forLoopVariableRegistry = VariableRegistry(topVariableRegistry: self.variableRegistry)
                try forLoopVariableRegistry.registerVariable(name: controlVariableName, variable: .primitive(.integer(controlVariableInitialValue)))
                // append statement 3 to be executed after each loop
                var body = result.body
                body.append(contentsOf: result.finalExpression)
                let conditionEvaluator = ConditionEvaluator(variableRegistry: forLoopVariableRegistry)
                forLoop: while (try conditionEvaluator.check(tokens: result.condition)) {
                    if case .aborted(let reason) = self.state { throw ParserError.aborted(description: reason) }
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
            case .switch:
                let switchBlock = try blockParser.getSwitchBlock(switchTokenIndex: self.currentIndex)
                self.currentIndex += switchBlock.consumedTokens

                var controlValue: Value?
                if switchBlock.variable.isFunction {
                    controlValue = try self.executeSubCodendAndGetValue(tokens: [.return].withAppended(switchBlock.variable), variableRegistry: self.variableRegistry)
                } else {
                    controlValue = ParserUtils.token2Value(switchBlock.variable, variableRegistry: self.variableRegistry)
                }
                guard let controlValue = controlValue else {
                    throw ParserError.syntaxError(description: "Could not calculate switch control value")
                }
                var performDefaultCase = true
                for (caseToken, body) in switchBlock.cases {
                    guard let caseValue = ParserUtils.token2Value(caseToken, variableRegistry: self.variableRegistry) else {
                        continue
                    }
                    if caseValue == controlValue {
                        performDefaultCase = false
                        let result = try self.executeSubCode(tokens: body, variableRegistry: self.variableRegistry)
                        switch result {
                        case .finished, .break:
                            break
                        case .return(let optional):
                            return .return(optional)
                        }
                    }
                }
                if performDefaultCase {
                    let result = try self.executeSubCode(tokens: switchBlock.default, variableRegistry: self.variableRegistry)
                    switch result {
                    case .finished, .break:
                        break
                    case .return(let optional):
                        return .return(optional)
                    }
                }
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
            case .defer:
                self.currentIndex += 1
                let deferredTokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: self.currentIndex, tokens: self.tokens)
                self.deferredTokens.append(deferredTokens)
                self.currentIndex += deferredTokens.count + 2
            case .variable(let name):
                try self.variableOperation(variableName: name)
            case .break:
                return .break
            case .return:
                try self.executeDeferredCode()
                self.currentIndex += 1
                if let returnedToken = self.tokens[safeIndex: self.currentIndex] {
                    if returnedToken.isLiteral || returnedToken.isVariable {
                        let returned = ParserUtils.token2Value(returnedToken, variableRegistry: self.variableRegistry)
                        Logger.v(self.logTag, "return \(returned?.asTypeValue ?? "nil")")
                        return .return(returned)
                    }
                    if returnedToken.isFunction {
                        let returned = try self.invokeFunctionAndGetValue()
                        Logger.v(self.logTag, "return \(returned.asTypeValue)")
                        return .return(returned)
                    }
                }
                Logger.v(self.logTag, "return nil")
                return .return(nil)
            case .semicolon, .this:
                self.currentIndex += 1
            default:
                throw ParserError.syntaxError(description: "Unexpected sign found: \(token)")
            }
        }
        try self.executeDeferredCode()
        self.state = .finished
        return .finished
    }

    private func invokeFunctionAndGetValue() throws -> Value {
        let result = try self.invokeFunction()
        switch result {
        case .finished, .break:
            throw ParserError.syntaxError(description: "function did not return any value!")
        case .return(let optional):
            guard let value = optional else {
                throw ParserError.syntaxError(description: "function did not return any value!")
            }
            return value
        }
    }

    private func invokeFunction() throws -> ParserExecResult {
        guard let token = self.tokens[safeIndex: self.currentIndex] else {
            throw ParserError.internalError(description: "invokeFunction called on nil token")
        }
        switch token {
        case .function(let name):
            self.currentIndex += 1
            if let localFunction = self.localFunctionRegistry.getFunction(name: name) {
                Logger.v(self.logTag, "invoke local function \(name)()")
                let variableRegistry = VariableRegistry(topVariableRegistry: self.variableRegistry)
                return try self.executeSubCode(tokens: localFunction.body, variableRegistry: variableRegistry)
            } else {
                return .return(try self.externalFunctionRegistry.callFunction(name: name))
            }

        case .functionWithArguments(let name):
            self.currentIndex += 1
            let argumentParser = FunctionArgumentParser(tokens: self.tokens, registerSet: self.registerSet)
            let parserResult = try argumentParser.getArgumentValues(index: self.currentIndex)
            self.currentIndex += parserResult.consumedTokens
            let values = parserResult.values

            if let localFunction = self.localFunctionRegistry.getFunction(name: name) {
                Logger.v(self.logTag, "invoke local function \(name)(\(values.map{ $0.asTypeValue }.joined(separator: ", ")))")
                let variableRegistry = VariableRegistry(topVariableRegistry: self.variableRegistry)
                guard localFunction.argumentNames.count == values.count else {
                    throw ParserError.syntaxError(description: "Function \(name) expects arguments \(localFunction.argumentNames) but provided \(values)")
                }
                try localFunction.argumentNames.enumerated().forEach { (index, name) in try variableRegistry.registerVariable(name: name, variable: .primitive(values[index])) }
                return try self.executeSubCode(tokens: localFunction.body, variableRegistry: variableRegistry)
            } else {
                return .return(try self.externalFunctionRegistry.callFunction(name: name, args: values))
            }
        default:
            throw ParserError.internalError(description: "invokeFunction called on \(token) token")
        }
    }

    func abort(reason: String) {
        self.state = .aborted(reason)
    }

    private func variableOperation(variableName: String) throws {
        self.currentIndex += 1
        guard let nextToken = self.tokens[safeIndex: self.currentIndex] else {
            return
        }

        switch nextToken {
        case .assign:
            self.currentIndex += 1
            let calculator = ArithmeticCalculator(tokens: self.tokens, registerSet: self.registerSet)
            let parserResult = try calculator.calculateValue(startIndex: self.currentIndex)
            self.currentIndex += parserResult.consumedTokens
            guard let value = parserResult.value else {
                throw ParserError.syntaxError(description: "Value not found for assigning variable \(variableName)")
            }
            try self.variableRegistry.updateVariable(name: variableName, variable: .primitive(value))
        case .increment:
            self.currentIndex += 1
            let variable = self.variableRegistry.getVariable(name: variableName)
            guard case .primitive(.integer(let intValue)) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Increment operation can be applied only for integer type, but \(type) found")
            }
            try self.variableRegistry.updateVariable(name: variableName, variable: .primitive(.integer(intValue + 1)))
        case .decrement:
            self.currentIndex += 1
            let variable = self.variableRegistry.getVariable(name: variableName)
            guard case .primitive(.integer(let intValue)) = variable else {
                let type = variable?.type ?? "nil"
                throw ParserError.syntaxError(description: "Decrement operation can be applied only for integer type, but \(type) found")
            }
            try self.variableRegistry.updateVariable(name: variableName, variable: .primitive(.integer(intValue - 1)))
        case .method(let methodName):
            // this case is responsible for invoking class' method
            _ = try self.callMethod(method: methodName, onVariable: variableName)
            self.currentIndex += 1
        case .methodWithArguments(let methodName):
            // this case is responsible for invoking class' method
            self.currentIndex += 1
            let argumentParser = FunctionArgumentParser(tokens: self.tokens, registerSet: self.registerSet)
            let parserResult = try argumentParser.getArgumentValues(index: self.currentIndex)
            self.currentIndex += parserResult.consumedTokens
            _ = try self.callMethod(method: methodName, onVariable: variableName, argumentValues: parserResult.values)
        case .attribute(let attributeName):
            // this case is responsible for updating class' instance attribute value
            guard let variable = self.variableRegistry.getVariable(name: variableName) else {
                throw ParserError.syntaxError(description: "Variable \(variableName) not found in the context!")
            }
            self.currentIndex += 1
            switch variable {
            case .class(let objectType, let attributesRegistry):
                guard attributesRegistry.variableExists(name: attributeName) else {
                    throw ParserError.syntaxError(description: "Variable \(variableName):\(objectType) has no attribute \(attributeName)")
                }
                guard let assignToken = self.tokens[safeIndex: self.currentIndex] else {
                    throw ParserError.syntaxError(description: "Unexpected code end after \(variableName).\(attributeName)")
                }
                guard case .assign = assignToken else {
                    throw ParserError.syntaxError(description: "Expected assign token(=) after \(variableName).\(attributeName) but found \(assignToken)")
                }
                self.currentIndex += 1
                let calculator = ArithmeticCalculator(tokens: self.tokens, registerSet: self.registerSet)
                let parserResult = try calculator.calculateValue(startIndex: self.currentIndex)
                self.currentIndex += parserResult.consumedTokens
                guard let value = parserResult.value else {
                    throw ParserError.syntaxError(description: "Could not determine value for \(variableName).\(attributeName)")
                }
                try attributesRegistry.updateVariable(name: attributeName, variable: .primitive(value))
            case .primitive:
                throw ParserError.syntaxError(description: "Variable \(variableName) is a primitive type. Cannot access attribute \(variableName).\(attributeName) on it")
            }
        default:
            break
        }
    }

    func callMethod(method methodName: String, onVariable variableName: String, argumentValues: [Value] = []) throws -> Value? {
        let variable = self.variableRegistry.getVariable(name: variableName)
        guard case .class(let type, let variableRegistry) = variable else {
            let type = variable?.type ?? "nil"
            throw ParserError.syntaxError(description: "Method call can be applied only for class type, but \(type) found")
        }
        guard let objectType = self.objectTypeRegistry.getObjectType(type) else {
            throw ParserError.syntaxError(description: "Could not find object type for variable \(variableName)")
        }
        guard let method = objectType.methodsRegistry.getFunction(name: methodName) else {
            throw ParserError.syntaxError(description: "ObjectType \(type) has no method \(methodName)")
        }
        Logger.v(self.logTag, "invoke method \(variableName).\(methodName)(\(argumentValues.map{ $0.asTypeValue }.joined(separator: ", "))) on type \(type)")
        Logger.v(self.logTag, "creating variableRegistry for method context")
        let methodVariableRegistry = VariableRegistry(topVariableRegistry: variableRegistry)
        if !argumentValues.isEmpty {
            guard method.argumentNames.count == argumentValues.count else {
                throw ParserError.syntaxError(description: "Method \(methodName) expects arguments \(method.argumentNames) but provided \(argumentValues)")
            }
            try method.argumentNames.enumerated().forEach { (index, name) in try methodVariableRegistry.registerVariable(name: name, variable: .primitive(argumentValues[index])) }
        }
        let result = try self.executeSubCode(tokens: method.body, variableRegistry: methodVariableRegistry)
        if case .return(let value) = result {
            return value
        }
        return nil
    }

    private func executeSubCode(tokens: [Token], variableRegistry topVariableRegistry: VariableRegistry) throws -> ParserExecResult {
        let variableRegistry = VariableRegistry(topVariableRegistry: topVariableRegistry)
        let localFunctionRegistry = LocalFunctionRegistry(topFunctionRegistry: self.localFunctionRegistry)
        let parser = Parser(tokens: tokens, externalFunctionRegistry: self.externalFunctionRegistry, localFunctionRegistry: localFunctionRegistry, variableRegistry: variableRegistry)
        return try parser.execute()
    }

    private func executeSubCodendAndGetValue(tokens: [Token], variableRegistry topVariableRegistry: VariableRegistry) throws -> Value {
        let result = try self.executeSubCode(tokens: tokens, variableRegistry: topVariableRegistry)
        switch result {
        case .finished, .break:
            throw ParserError.syntaxError(description: "function did not return any value!")
        case .return(let optional):
            guard let value = optional else {
                throw ParserError.syntaxError(description: "function did not return any value!")
            }
            return value
        }
    }

    func getValidatedArguments(_ tokens: [Token], for functioNname: String) throws -> [Value] {
        let arguments = tokens.filter { $0 != .comma }.filter { $0 != .this }
        let optionalArgumentValues = arguments.map { ParserUtils.token2Value($0, variableRegistry: self.variableRegistry) }
        if optionalArgumentValues.contains(nil) {
            throw ParserError.syntaxError(description: "Passed invalid arguments: \(optionalArgumentValues) to function \(functioNname)")
        }
        return optionalArgumentValues.compactMap{ $0 }
    }

    private func executeDeferredCode() throws {
        guard !self.deferredTokens.isEmpty else { return }
        Logger.v(self.logTag, "Executing deferred code")
        for tokens in self.deferredTokens.reversed() {
            _ = try self.executeSubCode(tokens: tokens, variableRegistry: self.variableRegistry)
        }
    }
}
