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
    case variableDefinition(type: String)
    case variable(name: String)
    case assign
    case add
    case sublime
    case bracketOpen
    case bracketClose
    case ifStatement
    case elseStatement
    case returnStatement
    case blockOpen
    case blockClose
    case equal
    case increment
    case decrement
    case notEqual
    case functionDefinition(type: String)
    case function(name: String)
    case functionWithArguments(name: String)
    case comma
    case andOperator
    case orOperator
    case semicolon
    case `break`
}

// MARK: regex for tokens

extension Token {
    static let generators: [TokenGenerator] = Token.makeTokenGenerators()
    
    private static func makeTokenGenerators() -> [TokenGenerator] {
        var generators: [TokenGenerator] = []
        
        generators.append(TokenGenerator(regex: "let", resolver: { _ in [.variableDefinition(type: "let")] }))
        generators.append(TokenGenerator(regex: "var", resolver: { _ in [.variableDefinition(type: "var")] }))
        generators.append(TokenGenerator(regex: "function", resolver: { _ in [.functionDefinition(type: "function")] }))
        generators.append(TokenGenerator(regex: "func", resolver: { _ in [.functionDefinition(type: "func")] }))
        generators.append(TokenGenerator(regex: "break", resolver: { _ in [.break] }))
        generators.append(TokenGenerator(regex: "true", resolver: { _ in [.boolLiteral(true)] }))
        generators.append(TokenGenerator(regex: "false", resolver: { _ in [.boolLiteral(false)] }))
        generators.append(TokenGenerator(regex: "if", resolver: { _ in [.ifStatement] }))
        generators.append(TokenGenerator(regex: ";", resolver: { _ in [.semicolon] }))
        generators.append(TokenGenerator(regex: "\\+\\+", resolver: { _ in [.increment] }))
        generators.append(TokenGenerator(regex: "\\-\\-", resolver: { _ in [.decrement] }))
        generators.append(TokenGenerator(regex: "\\+", resolver: { _ in [.add] }))
        generators.append(TokenGenerator(regex: "\\-", resolver: { _ in [.sublime] }))
        generators.append(TokenGenerator(regex: "&&", resolver: { _ in [.andOperator] }))
        generators.append(TokenGenerator(regex: "\\|\\|", resolver: { _ in [.orOperator] }))
        generators.append(TokenGenerator(regex: "\\{", resolver: { _ in [.blockOpen] }))
        generators.append(TokenGenerator(regex: "\\}", resolver: { _ in [.blockClose] }))
        generators.append(TokenGenerator(regex: "==", resolver: { _ in [.equal] }))
        generators.append(TokenGenerator(regex: "\\!=", resolver: { _ in [.notEqual] }))
        generators.append(TokenGenerator(regex: ",", resolver: { _ in [.comma] }))
        generators.append(TokenGenerator(regex: "else", resolver: { _ in [.elseStatement] }))
        generators.append(TokenGenerator(regex: "return", resolver: { _ in [.returnStatement] }))
        generators.append(TokenGenerator(regex: "=", resolver: { _ in [.assign] }))
        generators.append(TokenGenerator(regex: "\\(", resolver: { _ in [.bracketOpen] }))
        generators.append(TokenGenerator(regex: "\\)", resolver: { _ in [.bracketClose] }))
        generators.append(TokenGenerator(regex: "\\-?([0-9]*\\.[0-9]*)", resolver: { [.floatLiteral(Float($0)!)] }))
        generators.append(TokenGenerator(regex: "(\\d++)(?!\\.)", resolver: { [.intLiteral(Int($0)!)] }))
        generators.append(TokenGenerator(regex: "'[a-zA-Z_\\-0-9 ]*'", resolver: { [.stringLiteral($0.trimmingCharacters(in: CharacterSet(charactersIn: "'")))] }))
        generators.append(TokenGenerator(regex: "\"[a-zA-Z_\\-0-9 ']*\"", resolver: { [.stringLiteral($0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))] }))
        generators.append(TokenGenerator(regex: "[a-zA-Z0-9_]+\\(\\)", resolver: { [.function(name: $0.trimmingCharacters(in: CharacterSet(charactersIn: "()")))] }))
        generators.append(TokenGenerator(regex: "([a-zA-Z0-9_]+)\\((?!\\))", resolver: { [.functionWithArguments(name: $0.trimmingCharacters(in: CharacterSet(charactersIn: "()"))), .bracketOpen] }))
        generators.append(TokenGenerator(regex: "([a-zA-Z0-9_]+)", resolver: { [.variable(name: $0)] }))
        
        return generators
    }
}

typealias TokenResolver = (String) -> [Token]?
struct TokenGenerator {
    
    let regex: String
    let resolver: TokenResolver
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
        case .bracketClose:
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
        case .equal:
            return "=="
        case .notEqual:
            return "!="
        case .function(let name):
            return "function:\(name)"
        case .functionWithArguments(let name):
            return "functionWithArguments:\(name)"
        case .comma:
            return ","
        case .andOperator:
            return "and"
        case .orOperator:
            return "or"
        case .semicolon:
            return ";"
        case .variable(let name):
            return "variable(\(name))"
        case .variableDefinition(let type):
            return "variableDefinition(\(type))"
        case .assign:
            return "="
        case .add:
            return "+"
        case .sublime:
            return "-"
        case .functionDefinition(let type):
            return "functionDefinition(\(type))"
        case .break:
            return "break"
        case .increment:
            return "++"
        case .decrement:
            return "--"
        }
    }
}
