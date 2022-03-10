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
    func compare(left: Token, right: Token, variableRegistry: VariableRegistry) throws -> ValueComparatorResult {
        switch (left, right) {
        case (.intLiteral(let leftValue), .intLiteral(let rightValue)):
            return self.prepareResult(left: leftValue, right: rightValue)
        case (.intLiteral(let literalValue), .variable(let variableName)):
            guard let variable = ParserUtils.token2Value(right, variableRegistry: variableRegistry) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(variableName) not found!")
            }
            guard case .integer(let value) = variable else {
                throw ValueComparatorError.runtimeError(info: "Integer expected but \(variable.type) found!")
            }
            return self.prepareResult(left: literalValue, right: value)
        case (.variable(let variableName), .intLiteral(let literalValue)):
            guard let variable = ParserUtils.token2Value(left, variableRegistry: variableRegistry) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(variableName) not found!")
            }
            guard case .integer(let value) = variable else {
                throw ValueComparatorError.runtimeError(info: "Integer expected but \(variable.type) found!")
            }
            return self.prepareResult(left: value, right: literalValue)
        case (.floatLiteral(let leftValue), .floatLiteral(let rightValue)):
            return self.prepareResult(left: leftValue, right: rightValue)
        case (.floatLiteral(let literalValue), .variable(let variableName)):
            guard let variable = ParserUtils.token2Value(right, variableRegistry: variableRegistry) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(variableName) not found!")
            }
            guard case .float(let value) = variable else {
                throw ValueComparatorError.runtimeError(info: "Float expected but \(variable.type) found!")
            }
            return self.prepareResult(left: literalValue, right: value)
        case (.variable(let variableName), .floatLiteral(let literalValue)):
            guard let variable = ParserUtils.token2Value(left, variableRegistry: variableRegistry) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(variableName) not found!")
            }
            guard case .float(let value) = variable else {
                throw ValueComparatorError.runtimeError(info: "Float expected but \(variable.type) found!")
            }
            return self.prepareResult(left: value, right: literalValue)
        case (.variable(let leftVariableName), .variable(let rightVariableName)):
            guard let leftValue = ParserUtils.token2Value(left, variableRegistry: variableRegistry) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(leftVariableName) not found!")
            }
            guard let rightValue = ParserUtils.token2Value(right, variableRegistry: variableRegistry) else {
                throw ValueComparatorError.runtimeError(info: "Variable \(rightVariableName) not found!")
            }
            guard rightValue.type == leftValue.type else {
                throw ValueComparatorError.runtimeError(info: "\(leftValue.type) and \(rightValue.type) cannot be compared! Variables \(leftVariableName) and \(rightVariableName)")
            }
            return try self.prepareResult(left: leftValue, right: rightValue)
        default:
            throw ValueComparatorError.runtimeError(info: "\(left) and \(right) cannot be compared")
        }
    }

    private func prepareResult<T: Comparable>(left: T, right: T) -> ValueComparatorResult {
        if left == right {
            return .equal
        }
        if left > right {
            return .leftGreater
        }
        return .rightGreater
    }

    private func prepareResult(left: Value, right: Value) throws -> ValueComparatorResult {
        switch (left, right) {
        case (.integer(let leftValue), .integer(let rightValue)):
            return self.prepareResult(left: leftValue, right: rightValue)
        case (.float(let leftValue), .float(let rightValue)):
            return self.prepareResult(left: leftValue, right: rightValue)
        default:
            throw ValueComparatorError.runtimeError(info: "\(left) and \(right) cannot be compared")
        }
    }
}
