//
//  FunctionArgumentParser.swift
//
//
//  Created by Tomasz KUCHARSKI on 10/11/2022.
//

import Foundation

struct FunctionArgumentParserResult {
    let values: [Value]
    let consumedTokens: Int
}

class FunctionArgumentParser {
    private let logTag = "🦜 FunctionArgumentParser"
    let tokens: [Token]
    // we need all the registers, because calculator is capable of calling functions and resolving variables
    let registerSet: RegisterSet

    init(tokens: [Token], registerSet: RegisterSet) {
        self.tokens = tokens
        self.registerSet = registerSet
    }

    // index is position of opening backet's
    func getArgumentValues(index: Int) throws -> FunctionArgumentParserResult {
        var consumedTokens = 2 // two as there are two brackets

        let argumentTokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: index, tokens: self.tokens)
        consumedTokens += argumentTokens.count

        let arguments = argumentTokens.filter{ $0 != .this }.split(by: .comma)
        var values: [Value] = []
        for argument in arguments {
            let calculator = ArithmeticCalculator(tokens: argument, registerSet: self.registerSet)
            if let value = try calculator.calculateValue(startIndex: 0).value {
                values.append(value)
            }
        }
        return FunctionArgumentParserResult(values: values, consumedTokens: consumedTokens)
    }
}
