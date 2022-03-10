//
//  ConditionEvaluator.swift
//
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation

enum ConditionEvaluatorError: Error {
    case syntaxError(info: String)
}

extension ConditionEvaluatorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("ConditionEvaluatorError.syntaxError: \(info)", comment: "ConditionEvaluatorError")
        }
    }
}

class ConditionEvaluator {
    private let variableRegistry: VariableRegistry

    init(variableRegistry: VariableRegistry) {
        self.variableRegistry = variableRegistry
    }

    func check(tokens: [Token]) throws -> Bool {
        guard tokens.count > 0 else {
            throw ConditionEvaluatorError.syntaxError(info: "Empty condition")
        }
        if tokens.count == 1 {
            return try self.evaluateBoolVariable(token: tokens.first!)
        }
        if tokens.count == 3 {
            guard let left = tokens[safeIndex: 0],
                  let operation = tokens[safeIndex: 1],
                  let right = tokens[safeIndex: 2] else {
                throw ConditionEvaluatorError.syntaxError(info: "Invalid arguments for condition checking")
            }
            switch operation {
            case .equal:
                return try self.areEqual(left: left, right: right)
            case .notEqual:
                return try !self.areEqual(left: left, right: right)
            case .less:
                return try ValueComparator().compare(left: left, right: right, variableRegistry: self.variableRegistry) == .rightGreater
            case .greater:
                return try ValueComparator().compare(left: left, right: right, variableRegistry: self.variableRegistry) == .leftGreater
            case .lessOrEqual:
                let result = try ValueComparator().compare(left: left, right: right, variableRegistry: self.variableRegistry)
                return [ValueComparatorResult.equal, ValueComparatorResult.rightGreater].contains(result)
            case .greaterOrEqual:
                let result = try ValueComparator().compare(left: left, right: right, variableRegistry: self.variableRegistry)
                return [ValueComparatorResult.equal, ValueComparatorResult.leftGreater].contains(result)
            case .assign:
                throw ConditionEvaluatorError.syntaxError(info: "Did you mean `==` instead of `=`?")
            default:
                break
            }
        }
        if tokens.contains(.andOperator) {
            let segments = tokens.split(by: .andOperator)
            let evaluator = ConditionEvaluator(variableRegistry: self.variableRegistry)
            for condition in segments {
                let result = try evaluator.check(tokens: condition)
                if !result {
                    return false
                }
            }
            return true
        }
        if tokens.contains(.orOperator) {
            let segments = tokens.split(by: .orOperator)
            let evaluator = ConditionEvaluator(variableRegistry: self.variableRegistry)
            for condition in segments {
                let result = try evaluator.check(tokens: condition)
                if result {
                    return true
                }
            }
            return false
        }
        throw ConditionEvaluatorError.syntaxError(info: "Sorry, only basic condition checking is implemented")
    }

    private func evaluateBoolVariable(token: Token) throws -> Bool {
        switch token {
        case .boolLiteral(let value):
            return value
        case .variable(let name):
            guard let variable = self.variableRegistry.getValue(name: name) else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) not exists or not initialized")
            }
            switch variable {
            case .bool(let bool):
                return bool
            default:
                throw ConditionEvaluatorError.syntaxError(info: "Condition checking requires bool variable")
            }
        default:
            throw ConditionEvaluatorError.syntaxError(info: "Condition checking requires bool variable")
        }
    }

    private func areEqual(left: Token, right: Token) throws -> Bool {
        switch (left, right) {
        // both literals
        case (.intLiteral(_), .intLiteral(_)),
             (.floatLiteral(_), .floatLiteral(_)),
             (.stringLiteral(_), .stringLiteral(_)),
             (.boolLiteral(_), .boolLiteral(_)):
            return left == right
        case (.variable(let leftName), .variable(let rightName)):
            guard let leftValue = ParserUtils.token2Value(left, variableRegistry: self.variableRegistry) else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(leftName) not exists or not initialized")
            }
            guard let rightValue = ParserUtils.token2Value(right, variableRegistry: self.variableRegistry) else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(rightName) not exists or not initialized")
            }
            guard leftValue.type == rightValue.type else {
                throw ConditionEvaluatorError.syntaxError(info: "Variables are not comaprable. Left is \(leftValue.type) but right is \(rightValue.type)")
            }
            return leftValue == rightValue
        // variations of literals and variables
        case (.variable(let name), .intLiteral(let literalValue)),
             (.intLiteral(let literalValue), .variable(let name)):
            guard let variable = self.variableRegistry.getValue(name: name) else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) not exists or not initialized")
            }
            guard case .integer(let variableValue) = variable else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) has incompatible type. Integer expected")
            }
            return variableValue == literalValue
        case (.variable(let name), .floatLiteral(let literalValue)),
             (.floatLiteral(let literalValue), .variable(let name)):
            guard let variable = self.variableRegistry.getValue(name: name) else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) not exists or not initialized")
            }
            guard case .float(let variableValue) = variable else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) has incompatible type. Float expected")
            }
            return variableValue == literalValue
        case (.variable(let name), .stringLiteral(let literalValue)),
             (.stringLiteral(let literalValue), .variable(let name)):
            guard let variable = self.variableRegistry.getValue(name: name) else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) not exists or not initialized")
            }
            guard case .string(let variableValue) = variable else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) has incompatible type. String expected")
            }
            return variableValue == literalValue
        case (.variable(let name), .boolLiteral(let literalValue)),
             (.boolLiteral(let literalValue), .variable(let name)):
            guard let variable = self.variableRegistry.getValue(name: name) else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) not exists or not initialized")
            }
            guard case .bool(let variableValue) = variable else {
                throw ConditionEvaluatorError.syntaxError(info: "Variable \(name) has incompatible type. Bool expected")
            }
            return variableValue == literalValue
        default:
            throw ConditionEvaluatorError.syntaxError(info: "Condition for the types not supported")
        }
    }
}
