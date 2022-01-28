//
//  FunctionRegistry.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

class FunctionRegistry {
    private var functions: [String:()->()] = [:]
    private var functionsWithArgs: [String:([Value])->()] = [:]
    
    func registerFunc(name: String, function: @escaping ()->()) {
        self.functions[name] = function
    }
    
    func registerFunc(name: String, function: @escaping ([Value])->()) {
        self.functionsWithArgs[name] = function
    }
    
    func callFunction(name: String) {
        self.functions[name]?()
    }
    
    func callFunction(name: String, args: [Value]) {
        self.functionsWithArgs[name]?(args)
    }
}
