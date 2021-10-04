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
            "'[a-zA-Z_\\-0-9 ]*'": { .stringLiteral($0.trimmingCharacters(in: CharacterSet(charactersIn: "'"))) },
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
            return "floatLiteral(\(value))"
        case .intLiteral(let value):
            return "intLiteral(\(value))"
        case .bracketOpen:
            return "("
        case .braketClose:
            return ")"
        case .blockOpen:
            return "{"
        case .blockClose:
            return "}"
        case .ifStatement:
            return "if"
        case .boolLiteral(let value):
            return "boolLiteral(\(value))"
        case .stringLiteral(let value):
            return "stringLiteral(\(value))"
        case .elseStatement:
            return "else"
        case .returnStatement:
            return "return"
        case .equals:
            return "equals"
        }
    }
}
