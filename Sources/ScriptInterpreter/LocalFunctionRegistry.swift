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
    private let topFunctionRegistry: LocalFunctionRegistry?
    
    init(topFunctionRegistry: LocalFunctionRegistry? = nil) {
        self.functions = [:]
        self.topFunctionRegistry = topFunctionRegistry
    }
    
    func register(_ localFunction: LocalFunction) {
        self.functions[localFunction.name] = localFunction
    }
    
    func getFunction(name: String) -> LocalFunction? {
        return self.functions[name] ?? self.topFunctionRegistry?.getFunction(name: name)
    }
}
