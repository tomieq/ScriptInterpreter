//
//  Parser.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

class Parser {
    private let lexer: Lexer
    private let functionRegistry: FunctionRegistry
    
    init(lexer: Lexer, functionRegistry: FunctionRegistry) {
        self.lexer = lexer
        self.functionRegistry = functionRegistry
    }
    
    func execute() {
        for token in self.lexer.tokens {
            switch token {
            case .function(let name):
                self.functionRegistry.callFunction(name: name)
            default:
                break
            }
        }
    }
}
