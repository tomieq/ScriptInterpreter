//
//  ParserUtils.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum ParserUtilsError: Error {
    case invalidOpeningToken(given: Token?, expected: Token)
}

extension ParserUtilsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidOpeningToken(let given, let expected):
            return NSLocalizedString("ParserUtilsError.invalidOpeningToken. Expected \(expected) but found \(given?.debugDescription ?? "nil")", comment: "ParserUtilsError")
        }
    }
}

class ParserUtils {
    static func token2Value(_ token: Token, valueRegistry: ValueRegistry) -> Value? {
        switch token {
        case .intLiteral(let value):
            return .integer(value)
        case .stringLiteral(let value):
            return .string(value)
        case .boolLiteral(let value):
            return .bool(value)
        case .floatLiteral(let value):
            return .float(value)
        case .variable(let name):
            return valueRegistry.getValue(name: name)
        default:
            return nil
        }
    }
    
    static func getTokensBetweenBrackets(indexOfOpeningBracket index: Int, tokens: [Token]) throws -> [Token] {
        return try ParserUtils.getTokensClosedBetween(searchable: tokens, openingIndex: index, barriers: (.bracketOpen, .bracketClose))
    }
    
    static func getTokensForBlock(indexOfOpeningBlock index: Int, tokens: [Token]) throws -> [Token] {
        return try ParserUtils.getTokensClosedBetween(searchable: tokens, openingIndex: index, barriers: (.blockOpen, .blockClose))
    }
    
    private static func getTokensClosedBetween(searchable tokens: [Token], openingIndex index: Int, barriers: (start: Token, end: Token)) throws -> [Token] {
        guard let openingToken = tokens[safeIndex: index] else {
            throw ParserUtilsError.invalidOpeningToken(given: nil, expected: barriers.start)
        }
        
        guard case barriers.start = openingToken else {
            throw ParserUtilsError.invalidOpeningToken(given: openingToken, expected: barriers.start)
        }
        var brackerCounter = 1
        var result: [Token] = []
        var nextIndex = index + 1
        while let nextToken = tokens[safeIndex: nextIndex] {
            if nextToken == barriers.start {
                brackerCounter += 1
            }
            if nextToken == barriers.end {
                brackerCounter -= 1
            }
            if brackerCounter == 0 {
                break
            }
            result.append(nextToken)
            
            nextIndex += 1
        }
        return result
    }
}
