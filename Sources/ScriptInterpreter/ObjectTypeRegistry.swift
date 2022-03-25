//
//  ObjectTypeRegistry.swift
//
//
//  Created by Tomasz on 25/03/2022.
//

import Foundation

class ObjectTypeRegistry {
    private var objectTypes: [String: ObjectType] = [:]

    func register(objectType: ObjectType) {
        self.objectTypes[objectType.name] = objectType
    }

    func getObjectType(_ name: String) -> ObjectType? {
        return self.objectTypes[name]
    }
}

struct ObjectType {
    let name: String
    let methodsRegistry: LocalFunctionRegistry
}
