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
    private let logTag = "🐡 ExternalFunctionRegistry"
    private var functions: [String: () throws -> ()] = [:]
    private var functionsWithArgs: [String: ([Value]) throws -> ()] = [:]
    private var returningFunctions: [String: () throws -> Value] = [:]
    private var returningFunctionsWithArgs: [String: ([Value]) throws -> Value] = [:]

    func registerFunc(name: String, function: @escaping () throws -> ()) throws {
        if self.functions.keys.contains(name) {
            throw ExternalFunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.functions[name] = function
        Logger.v(self.logTag, "registered function \(name)()")
    }

    func registerFunc(name: String, function: @escaping () throws -> Value) throws {
        if self.functions.keys.contains(name) {
            throw ExternalFunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.returningFunctions[name] = function
        Logger.v(self.logTag, "registered returning function \(name)()")
    }

    func registerFunc(name: String, function: @escaping ([Value]) throws -> ()) throws {
        if self.functionsWithArgs.keys.contains(name) {
            throw ExternalFunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.functionsWithArgs[name] = function
        Logger.v(self.logTag, "registered function \(name)(_ values: Value...)")
    }

    func registerFunc(name: String, function: @escaping ([Value]) throws -> Value) throws {
        if self.functionsWithArgs.keys.contains(name) {
            throw ExternalFunctionRegistryError.functionAlreadyRegistered(name: name)
        }
        self.returningFunctionsWithArgs[name] = function
        Logger.v(self.logTag, "registered returning function \(name)(_ values: Value...)")
    }

    func callFunction(name: String) throws -> Value? {
        Logger.v(self.logTag, "invoke function \(name)()")
        if let function = self.functions[name] {
            try function()
            return nil
        } else if let function = self.returningFunctions[name] {
            return try function()
        } else {
            Logger.e(self.logTag, "Could not find function \(name)")
            throw ExternalFunctionRegistryError.functionNotFound(signature: "\(name)()")
        }
    }

    func callFunction(name: String, args: [Value]) throws -> Value? {
        Logger.v(self.logTag, "invoke function \(name)(\(args.map{ $0.asTypeValue }.joined(separator: ", ")))")
        if let function = self.functionsWithArgs[name] {
            try function(args)
            return nil
        } else if let function = self.returningFunctionsWithArgs[name] {
            return try function(args)
        } else {
            throw ExternalFunctionRegistryError.functionNotFound(signature: "\(name)(\(args.map{ $0.type }.joined(separator: ", ")))")
        }
    }
}
