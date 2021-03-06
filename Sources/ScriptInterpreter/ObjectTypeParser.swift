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
    private let tokens: [Token]

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse(objectTypeDefinitionIndex index: Int, into registry: ObjectTypeRegistry) throws -> Int {
        var currentIndex = index
        guard let token = self.tokens[safeIndex: currentIndex] else {
            throw ObjectTypeParserError.syntaxError(description: "Token not found at index \(index)")
        }
        guard case Token.class(let className) = token else {
            throw ObjectTypeParserError.syntaxError(description: "Token not found at index \(index)")
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
        let variableParser = VariableParser(tokens: tokens)

        let methodRegistry = LocalFunctionRegistry()
        let attributesRegistry = VariableRegistry()

        while let token = tokens[safeIndex: currentIndex] {
            switch token {
            case .functionDefinition(_):
                let consumedTokens = try functionParser.parse(functionTokenIndex: currentIndex, into: methodRegistry)
                currentIndex += consumedTokens
            case .variableDefinition(_), .constantDefinition(_):
                let consumedTokens = try variableParser.parse(variableDefinitionIndex: currentIndex, into: attributesRegistry)
                currentIndex += consumedTokens
            case .semicolon:
                currentIndex += 1
            default:
                throw ObjectTypeParserError.syntaxError(description: "Unexpected sign found: \(token)")
            }
        }
        return ObjectType(name: name, attributesRegistry: attributesRegistry, methodsRegistry: methodRegistry)
    }
}
