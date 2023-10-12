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
    case this
    case `nil`
    case assign
    case add
    case subtract
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
    case method(name: String)
    case methodWithArguments(name: String)
    case swiftReturnSign
    case attribute(name: String)
    case comma
    case underscore
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
            TokenGenerator(regex: "let\\s", { _ in [.constantDefinition(type: "let")] }),
            TokenGenerator(regex: "const\\s", { _ in [.constantDefinition(type: "const")] }),
            TokenGenerator(regex: "var\\s", { _ in [.variableDefinition(type: "var")] }),
            TokenGenerator(regex: "nil\\b", { _ in [.nil] }),
            TokenGenerator(regex: "null\\b", { _ in [.nil] }),
            TokenGenerator(regex: "Null\\b", { _ in [.nil] }),
            TokenGenerator(regex: "self\\.\\b", { _ in [.this] }),
            TokenGenerator(regex: "function\\s", { _ in [.functionDefinition(type: "function")] }),
            TokenGenerator(regex: "func\\s", { _ in [.functionDefinition(type: "func")] }),
            TokenGenerator(regex: "\\-\\>\\s", { _ in [.swiftReturnSign] }),
            TokenGenerator(regex: "class\\s[a-zA-Z0-9_]+", { [.class(name: $0.trimming("class "))] }),
            TokenGenerator(regex: "init\\(\\)", { _ in [.functionDefinition(type: "init"), .function(name: "init")] }),
            TokenGenerator(regex: "constructor\\(\\)", { _ in [.functionDefinition(type: "constructor"), .function(name: "init")] }),
            TokenGenerator(regex: "init\\((?!\\))", { _ in [.functionDefinition(type: "init"), .functionWithArguments(name: "init"), .bracketOpen] }),
            TokenGenerator(regex: "constructor\\((?!\\))", { _ in [.functionDefinition(type: "constructor"), .functionWithArguments(name: "init"), .bracketOpen] }),
            TokenGenerator(regex: "break\\b", { _ in [.break] }),
            TokenGenerator(regex: "return\\b", { _ in [.return] }),
            TokenGenerator(regex: "true\\b", { _ in [.boolLiteral(true)] }),
            TokenGenerator(regex: "false\\b", { _ in [.boolLiteral(false)] }),
            TokenGenerator(regex: "if\\b", { _ in [.ifStatement] }),
            TokenGenerator(regex: "while\\b", { _ in [.whileLoop] }),
            TokenGenerator(regex: "for\\b", { _ in [.forLoop] }),
            TokenGenerator(regex: "switch\\b", { _ in [.switch] }),
            TokenGenerator(regex: "case\\b", { _ in [.case] }),
            TokenGenerator(regex: "default\\b", { _ in [.default] }),
            TokenGenerator(regex: "defer\\b", { _ in [.defer] }),
            TokenGenerator(regex: "_\\b", { _ in [.underscore] }),
            TokenGenerator(regex: ";", { _ in [.semicolon] }),
            TokenGenerator(regex: ":", { _ in [.colon] }),
            TokenGenerator(regex: "\\+\\+", { _ in [.increment] }),
            TokenGenerator(regex: "\\-\\-", { _ in [.decrement] }),
            TokenGenerator(regex: "\\+", { _ in [.add] }),
            TokenGenerator(regex: "\\-", { _ in [.subtract] }),
            TokenGenerator(regex: "&&", { _ in [.andOperator] }),
            TokenGenerator(regex: "and\\b", { _ in [.andOperator] }),
            TokenGenerator(regex: "\\|\\|", { _ in [.orOperator] }),
            TokenGenerator(regex: "or\\b", { _ in [.orOperator] }),
            TokenGenerator(regex: "\\{", { _ in [.blockOpen] }),
            TokenGenerator(regex: "\\}", { _ in [.blockClose] }),
            TokenGenerator(regex: "<=", { _ in [.lessOrEqual] }),
            TokenGenerator(regex: ">=", { _ in [.greaterOrEqual] }),
            TokenGenerator(regex: "<", { _ in [.less] }),
            TokenGenerator(regex: ">", { _ in [.greater] }),
            TokenGenerator(regex: "==", { _ in [.equal] }),
            TokenGenerator(regex: "\\!=", { _ in [.notEqual] }),
            TokenGenerator(regex: ",", { _ in [.comma] }),
            TokenGenerator(regex: "else\\b", { _ in [.elseStatement] }),
            TokenGenerator(regex: "=", { _ in [.assign] }),
            TokenGenerator(regex: "\\(", { _ in [.bracketOpen] }),
            TokenGenerator(regex: "\\)", { _ in [.bracketClose] }),
            TokenGenerator(regex: "\\-?([0-9]*\\.[0-9]+)", { [.floatLiteral(Float($0)!)] }),
            TokenGenerator(regex: "(\\d++)(?!\\.)", { [.intLiteral(Int($0)!)] }),
            TokenGenerator(regex: "'[^']*'", { [.stringLiteral($0.trimming("'"))] }),
            TokenGenerator(regex: "\"[^\"]*\"", { [.stringLiteral($0.trimming("\""))] }),
            TokenGenerator(regex: "\\.[a-zA-Z0-9_]+\\(\\)", { [.method(name: $0.trimming(".()"))] }),
            TokenGenerator(regex: "\\.([a-zA-Z0-9_]+)\\((?!\\))", { [.methodWithArguments(name: $0.trimming(".()")), .bracketOpen] }),
            TokenGenerator(regex: "\\.[a-zA-Z0-9_]+", { [.attribute(name: $0.trimming("."))] }),
            TokenGenerator(regex: "[a-zA-Z0-9_]+\\(\\)", { [.function(name: $0.trimming("()"))] }),
            TokenGenerator(regex: "([a-zA-Z0-9_]+)\\((?!\\))", { [.functionWithArguments(name: $0.trimming("()")), .bracketOpen] }),
            TokenGenerator(regex: "([a-zA-Z0-9_]+)", { [.variable(name: $0)] }),
        ]
    }
}

typealias TokenResolver = (String) -> [Token]?
struct TokenGenerator {
    let regex: String
    let resolver: TokenResolver

    init(regex: String, _ resolver: @escaping TokenResolver) {
        self.regex = regex
        self.resolver = resolver
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
        case .this:
            return "self."
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
            return "function:\(name)()"
        case .functionWithArguments(let name):
            return "functionWithArguments:\(name)"
        case .method(let name):
            return "method:\(name)()"
        case .methodWithArguments(let name):
            return "methodWithArguments:\(name)"
        case .swiftReturnSign:
            return "funcReturnSign"
        case .attribute(let name):
            return "attribute:\(name)"
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
        case .subtract:
            return "-"
        case .underscore:
            return "_"
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
