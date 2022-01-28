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
}
