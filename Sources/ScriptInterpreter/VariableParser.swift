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
    private let logTag = "🐝 VariableParser"
    private let tokens: [Token]
    let registerSet: RegisterSet
    weak var parser: Parser?

    init(tokens: [Token], registerSet: RegisterSet, parser: Parser? = nil) {
        self.tokens = tokens
        self.registerSet = registerSet
        self.parser = parser
    }

    func parse(variableDefinitionIndex index: Int) throws -> Int {
        var currentIndex = index
        guard let token = self.tokens[safeIndex: currentIndex] else {
            throw VariableParserError.syntaxError(description: "Token not found at index \(index)")
        }
        currentIndex += 1

        func controlData() throws -> (definitionType: String, func: (String, Instance?) throws -> ()) {
            switch token {
            case .variableDefinition(let definitionType):
                return (definitionType, self.registerSet.variableRegistry.registerVariable)
            case .constantDefinition(let definitionType):
                return (definitionType, self.registerSet.variableRegistry.registerConstant)
            default:
                throw VariableParserError.syntaxError(description: "Improper token found at index \(index): \(token)")
            }
        }
        let controlData = try controlData()
        while let data = try self.initVariable(variableTokenIndex: currentIndex,
                                               definitionType: controlData.definitionType,
                                               register: controlData.func) {
            currentIndex += data.usedTokens
            if !data.shouldParseFurther {
                break
            }
        }
        return currentIndex - index
    }

    private func initVariable(variableTokenIndex pos: Int,
                              definitionType: String,
                              register: (String, Instance?) throws -> ()) throws -> (shouldParseFurther: Bool, usedTokens: Int)? {
        guard case .variable(let name) = self.tokens[safeIndex: pos] else {
            throw VariableParserError.syntaxError(description: "No variable name found after keyword \(definitionType) usage!")
        }
        var usedTokens = 1
        var shouldParseFurther = false
        if let nextToken = self.tokens[safeIndex: pos + 1], case .assign = nextToken {
            guard let valueToken = self.tokens[safeIndex: pos + 2] else {
                throw VariableParserError.syntaxError(description: "Value not found for assigning variable \(name)")
            }
            if case .nil = valueToken {
                try register(name, nil)
            } else {
                switch valueToken {
                // New class initialization
                case .function(let className), .functionWithArguments(let className):
                    if let objectType = self.registerSet.objectTypeRegistry.getObjectType(className) {
                        Logger.v(self.logTag, "creating attributesRegistry for class `\(className)` instance")
                        let attributesRegistry = objectType.attributesRegistry.makeCopy()
                        try register(name, .class(type: objectType.name, attributesRegistry: attributesRegistry))
                        // call initializer
                        var argumentValues: [Value] = []
                        if case .functionWithArguments = valueToken {
                            let argumentParser = FunctionArgumentParser(tokens: self.tokens, registerSet: self.registerSet)
                            let parserResult = try argumentParser.getArgumentValues(index: pos + 3)
                            usedTokens += parserResult.consumedTokens
                            argumentValues = parserResult.values
                        }
                        _ = try? self.parser?.callMethod(method: "init", onVariable: name, argumentValues: argumentValues)
                    } else {
                        fallthrough
                    }
                default:
                    let calculator = ArithmeticCalculator(tokens: self.tokens, registerSet: self.registerSet)
                    let parserResult = try calculator.calculateValue(startIndex: pos + 2)
                    usedTokens += parserResult.consumedTokens - 1
                    guard let value = parserResult.value else {
                        throw VariableParserError.syntaxError(description: "Value not found for assigning variable \(name)")
                    }
                    try register(name, .primitive(value))
                }
            }
            usedTokens += 2
        } else {
            try register(name, nil)
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
