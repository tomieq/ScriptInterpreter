//
//  ParserUtils.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

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
    
    static func getTokensBetweenBrackets(indexOfOpeningBracket index: Int, tokens: [Token]) -> [Token] {
        return ParserUtils.getTokensClosedBetween(searchable: tokens, openingIndex: index, barriers: (.bracketOpen, .bracketClose))
    }
    
    private static func getTokensClosedBetween(searchable tokens: [Token], openingIndex index: Int, barriers: (start: Token, end: Token)) -> [Token] {
        guard let openingToken = tokens[safeIndex: index] else {
            return []
        }
        
        guard case barriers.start = openingToken else {
            return []
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
