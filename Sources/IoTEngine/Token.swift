//
//  Token.swift
//  
//
//  Created by Tomasz Kucharski on 04/10/2021.
//

import Foundation


enum Token: Equatable {
    case floatLiteral(Float)
    case intLiteral(Int)
    case stringLiteral(String)
    case boolLiteral(Bool)
    case bracketOpen
    case braketClose
    case ifStatement
    case elseStatement
    case returnStatement
    case blockOpen
    case blockClose
    case equals
}

// MARK: regex for tokens

extension Token {
    typealias TokenGenerator = (String) -> Token?
    static var generators: [String: TokenGenerator] {
        return [
            "\\-?([0-9]*\\.[0-9]*)": { .floatLiteral(Float($0)!) },
            "(\\d++)(?!\\.)": { .intLiteral(Int($0)!) },
            "true": { _ in .boolLiteral(true) },
            "false": { _ in .boolLiteral(false) },
            "\"[a-zA-Z_\\-0-9 ']*\"": { .stringLiteral($0.trimmingCharacters(in: CharacterSet(charactersIn: "\""))) },
            "\\(": { _ in .bracketOpen },
            "\\)": { _ in .braketClose },
            "if": { _ in .ifStatement },
            "else": { _ in .elseStatement },
            "return": { _ in .returnStatement },
            "\\{": { _ in .blockOpen },
            "\\}": { _ in .blockClose },
            "==": { _ in .equals },
        ]
    }
}


extension Token: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .floatLiteral(let value):
            return "Token:floatLiteral(\(value))"
        case .intLiteral(let value):
            return "Token:intLiteral(\(value))"
        case .bracketOpen:
            return "Token:("
        case .braketClose:
            return "Token:)"
        case .blockOpen:
            return "Token:{"
        case .blockClose:
            return "Token:}"
        case .ifStatement:
            return "Token:if"
        case .boolLiteral(let value):
            return "Token:boolLiteral(\(value))"
        case .stringLiteral(let value):
            return "Token:string(\(value))"
        case .elseStatement:
            return "Token:else"
        case .returnStatement:
            return "Token:return"
        case .equals:
            return "Token:equals"
        }
    }
}
