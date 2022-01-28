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
    
    func check(tokens: [Token]) throws -> Bool {
        
        guard tokens.count > 0 else {
            throw ConditionEvaluatorError.syntaxError(info: "Empty condition")
        }
        return try self.evaluateBoolVariable(token: tokens.first!)
    }
    
    private func evaluateBoolVariable(token: Token) throws -> Bool {
        switch token {
        case .boolLiteral(let value):
            return value
        default:
            throw ConditionEvaluatorError.syntaxError(info: "Condition checking requires bool variable")
        }
    }
}
