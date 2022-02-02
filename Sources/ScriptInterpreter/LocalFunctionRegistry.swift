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
    private var functions: [LocalFunction]
    
    init() {
        self.functions = []
    }
    
    func register(_ localFunction: LocalFunction) {
        self.functions.append(localFunction)
    }
}
