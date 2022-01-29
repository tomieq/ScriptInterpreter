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
    
    private let valueRegistry: ValueRegistry
    
    init(valueRegistry: ValueRegistry) {
        self.valueRegistry = valueRegistry
    }
    
    func check(tokens: [Token]) throws -> Bool {
        
        guard tokens.count > 0 else {
            throw ConditionEvaluatorError.syntaxError(info: "Empty condition")
        }
        if tokens.count == 1 {
            return try self.evaluateBoolVariable(token: tokens.first!)
        }
        if tokens.contains(.equal) {
            guard let left = tokens[safeIndex: 0],
                  let right = tokens[safeIndex: 2] else {
                      throw ConditionEvaluatorError.syntaxError(info: "Invalid arguments for condition checking")
                  }
            return left == right
        }
        if tokens.contains(.notEqual) {
            guard let left = tokens[safeIndex: 0],
                  let right = tokens[safeIndex: 2] else {
                      throw ConditionEvaluatorError.syntaxError(info: "Invalid arguments for condition checking")
                  }
            return left != right
        }
        return false
    }
    
    private func evaluateBoolVariable(token: Token) throws -> Bool {
        switch token {
        case .boolLiteral(let value):
            return value
        case .variable(let name):
            guard let variable = self.valueRegistry.getValue(name: name) else {
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
}
