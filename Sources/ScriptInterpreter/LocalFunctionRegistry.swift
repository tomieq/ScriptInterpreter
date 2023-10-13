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

class LocalFunctionRegistryID {
    private static var counter = 0
    static var next: String {
        defer {
            Self.counter += 1
        }
        return String(format: "%03d", Self.counter)
    }
}

class LocalFunctionRegistry {
    private let logTag = "🐇 LocalFunctionRegistry"
    private var functions: [String: LocalFunction]
    private let topFunctionRegistry: LocalFunctionRegistry?
    private let id: String

    init(topFunctionRegistry: LocalFunctionRegistry? = nil, idPrefix: String? = nil) {
        self.id = idPrefix.isNil ? LocalFunctionRegistryID.next : "\(idPrefix.readable).\(LocalFunctionRegistryID.next)"
        self.functions = [:]
        self.topFunctionRegistry = topFunctionRegistry
        let parentID = topFunctionRegistry?.id
        let parentInfo = parentID.isNil ? "" : " to parentID: \(parentID!)"
        Logger.v(self.logTag, "Created new registry: \(self.id)" + parentInfo)
    }

    func register(_ localFunction: LocalFunction) {
        self.functions[localFunction.name] = localFunction
        Logger.v(self.logTag, "new function \(localFunction.name)(\(localFunction.argumentNames.joined(separator: ", "))) in registry: \(self.id)")
    }

    func getFunction(name: String) -> LocalFunction? {
        return self.functions[name] ?? self.topFunctionRegistry?.getFunction(name: name)
    }
}
