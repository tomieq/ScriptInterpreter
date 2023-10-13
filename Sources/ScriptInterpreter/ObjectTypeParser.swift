//
//  ObjectTypeParser.swift
//
//
//  Created by Tomasz on 25/03/2022.
//

import Foundation

enum ObjectTypeParserError: Error {
    case syntaxError(description: String)
}

extension ObjectTypeParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("VariableParserError.syntaxError: \(info)", comment: "VariableParserError")
        }
    }
}

class ObjectTypeParser {
    private let logTag = "🪰 ObjectTypeParser"
    private let tokens: [Token]
    private let registerSet: RegisterSet

    init(tokens: [Token], registerSet: RegisterSet) {
        self.tokens = tokens
        self.registerSet = registerSet
    }

    func parse(objectTypeDefinitionIndex index: Int, into registry: ObjectTypeRegistry) throws -> Int {
        var currentIndex = index
        guard let token = self.tokens[safeIndex: currentIndex] else {
            let info = "Token not found at index \(index)"
            Logger.e(self.logTag, info)
            throw ObjectTypeParserError.syntaxError(description: info)
        }
        guard case Token.class(let className) = token else {
            let info = "Unexpected token at index \(index). Should be class token but found \(token)"
            Logger.e(self.logTag, info)
            throw ObjectTypeParserError.syntaxError(description: info)
        }
        currentIndex += 1

        let bodyTokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)
        let objectType = try self.parseObjectBody(tokens: bodyTokens, name: className)
        registry.register(objectType: objectType)
        return 3 + bodyTokens.count
    }

    private func parseObjectBody(tokens: [Token], name: String) throws -> ObjectType {
        var currentIndex = 0
        let functionParser = FunctionParser(tokens: tokens)

        let methodRegistry = LocalFunctionRegistry(idPrefix: name)
        let registerSet = self.registerSet.copy(variableRegistry: VariableRegistry(idPrefix: name))
        let variableParser = VariableParser(tokens: tokens, registerSet: registerSet)

        while let token = tokens[safeIndex: currentIndex] {
            switch token {
            case .functionDefinition(_):
                let consumedTokens = try functionParser.parse(functionTokenIndex: currentIndex, into: methodRegistry)
                currentIndex += consumedTokens
            case .variableDefinition(_), .constantDefinition(_):
                let consumedTokens = try variableParser.parse(variableDefinitionIndex: currentIndex)
                currentIndex += consumedTokens
            case .semicolon:
                currentIndex += 1
            default:
                throw ObjectTypeParserError.syntaxError(description: "Unexpected sign found: \(token)")
            }
        }
        // if there is no explicit init, define empty one
        if methodRegistry.getFunction(name: "init").isNil {
            methodRegistry.register(LocalFunction(name: "init", argumentNames: [], body: []))
        }
        return ObjectType(name: name, attributesRegistry: registerSet.variableRegistry, methodsRegistry: methodRegistry)
    }
}
