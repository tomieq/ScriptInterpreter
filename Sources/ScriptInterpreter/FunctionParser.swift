//
//  FunctionParser.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation

enum FunctionParserError: Error {
    case syntaxError(description: String)
}

extension FunctionParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .syntaxError(let info):
            return NSLocalizedString("VariableParserError.syntaxError: \(info)", comment: "VariableParserError")
        }
    }
}
