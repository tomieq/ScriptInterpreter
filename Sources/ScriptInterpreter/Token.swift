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
    case constantDefinition(type: String)
    case variable(name: String)
    case `nil`
    case assign
    case add
    case sublime
    case bracketOpen
    case bracketClose
    case ifStatement
    case elseStatement
    case whileLoop
    case forLoop
    case blockOpen
    case blockClose
    case equal
    case less
    case greater
    case lessOrEqual
    case greaterOrEqual
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
    case `return`
}

// MARK: regex for tokens

extension Token {
    static let generators: [TokenGenerator] = Token.makeTokenGenerators()
    
    private static func makeTokenGenerators() -> [TokenGenerator] {
        var generators: [TokenGenerator] = []
        
        generators.append(TokenGenerator(regex: "let\\s", resolver: { _ in [.constantDefinition(type: "let")] }))
        generators.append(TokenGenerator(regex: "const\\s", resolver: { _ in [.constantDefinition(type: "const")] }))
        generators.append(TokenGenerator(regex: "var\\s", resolver: { _ in [.variableDefinition(type: "var")] }))
        generators.append(TokenGenerator(regex: "nil\\b", resolver: { _ in [.nil] }))
        generators.append(TokenGenerator(regex: "null\\b", resolver: { _ in [.nil] }))
        generators.append(TokenGenerator(regex: "Null\\b", resolver: { _ in [.nil] }))
        generators.append(TokenGenerator(regex: "function\\s", resolver: { _ in [.functionDefinition(type: "function")] }))
        generators.append(TokenGenerator(regex: "func\\s", resolver: { _ in [.functionDefinition(type: "func")] }))
        generators.append(TokenGenerator(regex: "break\\b", resolver: { _ in [.break] }))
        generators.append(TokenGenerator(regex: "return\\b", resolver: { _ in [.return] }))
        generators.append(TokenGenerator(regex: "true\\b", resolver: { _ in [.boolLiteral(true)] }))
        generators.append(TokenGenerator(regex: "false\\b", resolver: { _ in [.boolLiteral(false)] }))
        generators.append(TokenGenerator(regex: "if\\b", resolver: { _ in [.ifStatement] }))
        generators.append(TokenGenerator(regex: "while\\b", resolver: { _ in [.whileLoop] }))
        generators.append(TokenGenerator(regex: "for\\b", resolver: { _ in [.forLoop] }))
        generators.append(TokenGenerator(regex: ";", resolver: { _ in [.semicolon] }))
        generators.append(TokenGenerator(regex: "\\+\\+", resolver: { _ in [.increment] }))
        generators.append(TokenGenerator(regex: "\\-\\-", resolver: { _ in [.decrement] }))
        generators.append(TokenGenerator(regex: "\\+", resolver: { _ in [.add] }))
        generators.append(TokenGenerator(regex: "\\-", resolver: { _ in [.sublime] }))
        generators.append(TokenGenerator(regex: "&&", resolver: { _ in [.andOperator] }))
        generators.append(TokenGenerator(regex: "and\\b", resolver: { _ in [.andOperator] }))
        generators.append(TokenGenerator(regex: "\\|\\|", resolver: { _ in [.orOperator] }))
        generators.append(TokenGenerator(regex: "or\\b", resolver: { _ in [.orOperator] }))
        generators.append(TokenGenerator(regex: "\\{", resolver: { _ in [.blockOpen] }))
        generators.append(TokenGenerator(regex: "\\}", resolver: { _ in [.blockClose] }))
        generators.append(TokenGenerator(regex: "<=", resolver: { _ in [.lessOrEqual] }))
        generators.append(TokenGenerator(regex: ">=", resolver: { _ in [.greaterOrEqual] }))
        generators.append(TokenGenerator(regex: "<", resolver: { _ in [.less] }))
        generators.append(TokenGenerator(regex: ">", resolver: { _ in [.greater] }))
        generators.append(TokenGenerator(regex: "==", resolver: { _ in [.equal] }))
        generators.append(TokenGenerator(regex: "\\!=", resolver: { _ in [.notEqual] }))
        generators.append(TokenGenerator(regex: ",", resolver: { _ in [.comma] }))
        generators.append(TokenGenerator(regex: "else\\b", resolver: { _ in [.elseStatement] }))
        generators.append(TokenGenerator(regex: "=", resolver: { _ in [.assign] }))
        generators.append(TokenGenerator(regex: "\\(", resolver: { _ in [.bracketOpen] }))
        generators.append(TokenGenerator(regex: "\\)", resolver: { _ in [.bracketClose] }))
        generators.append(TokenGenerator(regex: "\\-?([0-9]*\\.[0-9]*)", resolver: { [.floatLiteral(Float($0)!)] }))
        generators.append(TokenGenerator(regex: "(\\d++)(?!\\.)", resolver: { [.intLiteral(Int($0)!)] }))
        generators.append(TokenGenerator(regex: "'[^']*'", resolver: { [.stringLiteral($0.trimmingCharacters(in: CharacterSet(charactersIn: "'")))] }))
        generators.append(TokenGenerator(regex: "\"[^\"]*\"", resolver: { [.stringLiteral($0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))] }))
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
        case .whileLoop:
            return "while"
        case .forLoop:
            return "for"
        case .boolLiteral(let value):
            return "boolLiteral(\(value))"
        case .stringLiteral(let value):
            return "stringLiteral(\(value))"
        case .elseStatement:
            return "else"
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
        case .constantDefinition(let type):
            return "constantDefinition(\(type))"
        case .nil:
            return "nil"
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
        case .return:
            return "return"
        case .increment:
            return "++"
        case .decrement:
            return "--"
        case .less:
            return "<"
        case .greater:
            return ">"
        case .lessOrEqual:
            return "<="
        case .greaterOrEqual:
            return ">="
        }
    }
}

extension Token {
    var isFunction: Bool {
        if case .function(_) = self {
            return true
        }
        if case .functionWithArguments(_) = self {
            return true
        }
        return false
    }
    
    var isVariable: Bool {
        if case .variable(_) = self {
            return true
        }
        return false
    }

    var isLiteral: Bool {
        if case .stringLiteral(_) = self {
            return true
        }
        if case .floatLiteral(_) = self {
            return true
        }
        if case .boolLiteral(_) = self {
            return true
        }
        if case .intLiteral(_) = self {
            return true
        }
        return false
    }
}
