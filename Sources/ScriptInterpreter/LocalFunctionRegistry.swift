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
    private let logTag = "🐇 LocalFunctionRegistry"
    private var functions: [String: LocalFunction]
    private let topFunctionRegistry: LocalFunctionRegistry?
    private let id = "0x".appendingRandomHexDigits(length: 4)

    init(topFunctionRegistry: LocalFunctionRegistry? = nil) {
        self.functions = [:]
        self.topFunctionRegistry = topFunctionRegistry
        let parentID = topFunctionRegistry?.id
        let parentInfo = parentID.isNil ? "" : " to parentID: \(parentID!)"
        Logger.v(self.logTag, "Created new registryID: \(self.id)" + parentInfo)
    }

    func register(_ localFunction: LocalFunction) {
        self.functions[localFunction.name] = localFunction
        Logger.v(self.logTag, "new function \(localFunction.name)(\(localFunction.argumentNames.joined(separator: ", "))) in registryID: \(self.id)")
    }

    func getFunction(name: String) -> LocalFunction? {
        return self.functions[name] ?? self.topFunctionRegistry?.getFunction(name: name)
    }
}
