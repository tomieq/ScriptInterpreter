//
//  FunctionRegistry.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum FunctionRegistryError: Error {
    case functionAlreadyRegistered(name: String)
    case functionNotFound(signature: String)
}

class FunctionRegistry {
    private var functions: [String:()->()] = [:]
    private var functionsWithArgs: [String:([Value])->()] = [:]
    
    func registerFunc(name: String, function: @escaping ()->()) throws {
        if self.functions.keys.contains(name) {
            throw FunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.functions[name] = function
    }
    
    func registerFunc(name: String, function: @escaping ([Value])->()) throws {
        if self.functionsWithArgs.keys.contains(name) {
            throw FunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.functionsWithArgs[name] = function
    }
    
    func callFunction(name: String) throws {
        if let function = self.functions[name] {
            function()
        } else {
            throw FunctionRegistryError.functionNotFound(signature: "\(name)()")
        }
    }

    func callFunction(name: String, args: [Value]) throws {
        if let function = self.functionsWithArgs[name] {
            function(args)
        } else {
            throw FunctionRegistryError.functionNotFound(signature: "\(name)(\(args.map{$0.type}.joined(separator: ", "))")
        }
    }
}
