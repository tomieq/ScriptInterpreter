//
//  ValueComparator.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation

enum ValueComparatorError: Error {
    case runtimeError(info: String)
}

extension ValueComparatorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .runtimeError(let info):
            return NSLocalizedString("ValueComparatorError.runtimeError: \(info)", comment: "ValueComparatorError")
        }
    }
}

enum ValueComparatorResult {
    case equal
    case leftGreater
    case rightGreater
}

class ValueComparator {
    
    func compare(left: Token, right: Token, variableRegister: ValueRegistry) throws -> ValueComparatorResult {
        switch (left, right) {
        case (.intLiteral(let leftValue), .intLiteral(let rightValue)):
            return self.prepareResult(left: leftValue, right: rightValue)
        case (.intLiteral(let literalValue), .variable(let variableName)):
            guard let variable = ParserUtils.token2Value(right, valueRegistry: variableRegister) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(variableName) not found!")
            }
            guard case .integer(let value) = variable else {
                throw ValueComparatorError.runtimeError(info: "Integer expected but \(variable.type) found!")
            }
            return self.prepareResult(left: literalValue, right: value)
        case (.variable(let variableName), .intLiteral(let literalValue)):
            guard let variable = ParserUtils.token2Value(left, valueRegistry: variableRegister) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(variableName) not found!")
            }
            guard case .integer(let value) = variable else {
                throw ValueComparatorError.runtimeError(info: "Integer expected but \(variable.type) found!")
            }
            return self.prepareResult(left: value, right: literalValue)
        default:
            throw ValueComparatorError.runtimeError(info: "\(left) and \(right) cannot be compared")
        }
    }
    
    private func prepareResult(left: Int, right: Int) -> ValueComparatorResult {
        if left == right {
            return .equal
        }
        if left > right {
            return .leftGreater
        }
        return .rightGreater
    }
}
