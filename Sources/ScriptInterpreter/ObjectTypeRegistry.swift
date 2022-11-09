//
//  ObjectTypeRegistry.swift
//
//
//  Created by Tomasz on 25/03/2022.
//

import Foundation

class ObjectTypeRegistry {
    private let logTag = "🦋 ObjectTypeRegistry"
    private var objectTypes: [String: ObjectType] = [:]
    private let id = "0x".appendingRandomHexDigits(length: 4)

    init() {
        Logger.v(self.logTag, "Created new registryID: \(self.id)")
    }

    func register(objectType: ObjectType) {
        self.objectTypes[objectType.name] = objectType
        Logger.v(self.logTag, "registered objectType: \(objectType.name) in registryID: \(self.id)")
    }

    func getObjectType(_ name: String) -> ObjectType? {
        return self.objectTypes[name]
    }
}

struct ObjectType {
    let name: String
    let attributesRegistry: VariableRegistry
    let methodsRegistry: LocalFunctionRegistry
}
