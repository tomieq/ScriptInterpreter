//
//  LocalFunctionRegistry.swift
//  
//
//  Created by Tomasz Kucharski on 02/02/2022.
//

import Foundation

struct LocalFunction {
    let name: String
    let argumentNames: [String]
    let body: [Token]
}

class LocalFunctionRegistry {
    private var functions: [String:LocalFunction]
    
    init() {
        self.functions = [:]
    }
    
    func register(_ localFunction: LocalFunction) {
        self.functions[localFunction.name] = localFunction
    }
    
    func getFunction(name: String) -> LocalFunction? {
        return self.functions[name]
    }
}
