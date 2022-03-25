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
            throw VariableParserError.syntaxError(description: "Token not found at index \(index)")
        }
        guard case Token.class(let className) = token else {
            throw VariableParserError.syntaxError(description: "Token not found at index \(index)")
        }
        let objectType = ObjectType(name: className, methods: [:])
        registry.register(objectType: objectType)
        currentIndex += 1

        let body = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: currentIndex, tokens: self.tokens)

        return 3 + body.count
    }
}
