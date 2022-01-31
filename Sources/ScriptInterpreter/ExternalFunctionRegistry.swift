//
//  ExternalFunctionRegistry.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum ExternalFunctionRegistryError: Error {
    case functionAlreadyRegistered(name: String)
    case functionNotFound(signature: String)
}

extension ExternalFunctionRegistryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .functionAlreadyRegistered(let name):
            return NSLocalizedString("ExternalFunctionRegistryError.functionAlreadyRegistered: function \(name) was registered before", comment: "ExternalFunctionRegistryError")
        case .functionNotFound(let signature):
            return NSLocalizedString("ExternalFunctionRegistryError.functionNotFound: function \(signature) was not registered in the context", comment: "ExternalFunctionRegistryError")
        }
    }
}

class ExternalFunctionRegistry {
    private var functions: [String:() throws ->()] = [:]
    private var functionsWithArgs: [String:([Value]) throws ->()] = [:]
    
    func registerFunc(name: String, function: @escaping () throws ->()) throws {
        if self.functions.keys.contains(name) {
            throw ExternalFunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.functions[name] = function
    }
    
    func registerFunc(name: String, function: @escaping ([Value]) throws ->()) throws {
        if self.functionsWithArgs.keys.contains(name) {
            throw ExternalFunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.functionsWithArgs[name] = function
    }
    
    func callFunction(name: String) throws {
        if let function = self.functions[name] {
            try function()
        } else {
            throw ExternalFunctionRegistryError.functionNotFound(signature: "\(name)()")
        }
    }

    func callFunction(name: String, args: [Value]) throws {
        if let function = self.functionsWithArgs[name] {
            try function(args)
        } else {
            throw ExternalFunctionRegistryError.functionNotFound(signature: "\(name)(\(args.map{$0.type}.joined(separator: ", ")))")
        }
    }
}
