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
    case `class`(name: String)
    case `nil`
    case assign
    case add
    case sublime
    case bracketOpen
    case bracketClose
    case ifStatement
    case elseStatement
    case `switch`
    case `case`
    case `default`
    case `defer`
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
    case colon
    case `break`
    case `return`
}

// MARK: regex for tokens

extension Token {
    static let generators: [TokenGenerator] = Token.makeTokenGenerators()

    private static func makeTokenGenerators() -> [TokenGenerator] {
        return [
            TokenGenerator(regex: "let\\s", resolver: { _ in [.constantDefinition(type: "let")] }),
            TokenGenerator(regex: "const\\s", resolver: { _ in [.constantDefinition(type: "const")] }),
            TokenGenerator(regex: "var\\s", resolver: { _ in [.variableDefinition(type: "var")] }),
            TokenGenerator(regex: "nil\\b", resolver: { _ in [.nil] }),
            TokenGenerator(regex: "null\\b", resolver: { _ in [.nil] }),
            TokenGenerator(regex: "Null\\b", resolver: { _ in [.nil] }),
            TokenGenerator(regex: "function\\s", resolver: { _ in [.functionDefinition(type: "function")] }),
            TokenGenerator(regex: "func\\s", resolver: { _ in [.functionDefinition(type: "func")] }),
            TokenGenerator(regex: "class\\s[a-zA-Z0-9_]+", resolver: { [.class(name: $0.trimming("class "))] }),
            TokenGenerator(regex: "break\\b", resolver: { _ in [.break] }),
            TokenGenerator(regex: "return\\b", resolver: { _ in [.return] }),
            TokenGenerator(regex: "true\\b", resolver: { _ in [.boolLiteral(true)] }),
            TokenGenerator(regex: "false\\b", resolver: { _ in [.boolLiteral(false)] }),
            TokenGenerator(regex: "if\\b", resolver: { _ in [.ifStatement] }),
            TokenGenerator(regex: "while\\b", resolver: { _ in [.whileLoop] }),
            TokenGenerator(regex: "for\\b", resolver: { _ in [.forLoop] }),
            TokenGenerator(regex: "switch\\b", resolver: { _ in [.switch] }),
            TokenGenerator(regex: "case\\b", resolver: { _ in [.case] }),
            TokenGenerator(regex: "default\\b", resolver: { _ in [.default] }),
            TokenGenerator(regex: "defer\\b", resolver: { _ in [.defer] }),
            TokenGenerator(regex: ";", resolver: { _ in [.semicolon] }),
            TokenGenerator(regex: ":", resolver: { _ in [.colon] }),
            TokenGenerator(regex: "\\+\\+", resolver: { _ in [.increment] }),
            TokenGenerator(regex: "\\-\\-", resolver: { _ in [.decrement] }),
            TokenGenerator(regex: "\\+", resolver: { _ in [.add] }),
            TokenGenerator(regex: "\\-", resolver: { _ in [.sublime] }),
            TokenGenerator(regex: "&&", resolver: { _ in [.andOperator] }),
            TokenGenerator(regex: "and\\b", resolver: { _ in [.andOperator] }),
            TokenGenerator(regex: "\\|\\|", resolver: { _ in [.orOperator] }),
            TokenGenerator(regex: "or\\b", resolver: { _ in [.orOperator] }),
            TokenGenerator(regex: "\\{", resolver: { _ in [.blockOpen] }),
            TokenGenerator(regex: "\\}", resolver: { _ in [.blockClose] }),
            TokenGenerator(regex: "<=", resolver: { _ in [.lessOrEqual] }),
            TokenGenerator(regex: ">=", resolver: { _ in [.greaterOrEqual] }),
            TokenGenerator(regex: "<", resolver: { _ in [.less] }),
            TokenGenerator(regex: ">", resolver: { _ in [.greater] }),
            TokenGenerator(regex: "==", resolver: { _ in [.equal] }),
            TokenGenerator(regex: "\\!=", resolver: { _ in [.notEqual] }),
            TokenGenerator(regex: ",", resolver: { _ in [.comma] }),
            TokenGenerator(regex: "else\\b", resolver: { _ in [.elseStatement] }),
            TokenGenerator(regex: "=", resolver: { _ in [.assign] }),
            TokenGenerator(regex: "\\(", resolver: { _ in [.bracketOpen] }),
            TokenGenerator(regex: "\\)", resolver: { _ in [.bracketClose] }),
            TokenGenerator(regex: "\\-?([0-9]*\\.[0-9]*)", resolver: { [.floatLiteral(Float($0)!)] }),
            TokenGenerator(regex: "(\\d++)(?!\\.)", resolver: { [.intLiteral(Int($0)!)] }),
            TokenGenerator(regex: "'[^']*'", resolver: { [.stringLiteral($0.trimming("'"))] }),
            TokenGenerator(regex: "\"[^\"]*\"", resolver: { [.stringLiteral($0.trimming("\""))] }),
            TokenGenerator(regex: "[a-zA-Z0-9_]+\\(\\)", resolver: { [.function(name: $0.trimming("()"))] }),
            TokenGenerator(regex: "([a-zA-Z0-9_]+)\\((?!\\))", resolver: { [.functionWithArguments(name: $0.trimming("()")), .bracketOpen] }),
            TokenGenerator(regex: "([a-zA-Z0-9_]+)", resolver: { [.variable(name: $0)] }),
        ]
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
        case .switch:
            return "switch"
        case .case:
            return "case"
        case .default:
            return "default"
        case .defer:
            return "defer"
        case .class(let name):
            return "class \(name)"
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
        case .colon:
            return ":"
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

extension Token: Hashable {}
