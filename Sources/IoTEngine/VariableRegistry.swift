//
//  VariableRegistry.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum ValueRegistryError: Error {
    case valueDoesNotExist(name: String)
    case typeMismatch(variableName: String, existingType: String, newType: String)
}

extension ValueRegistryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .valueDoesNotExist(let name):
            return NSLocalizedString("ValueRegistryError.valueDoesNotExist: variable \(name) was not defined", comment: "ValueRegistryError")
        case .typeMismatch(let variableName, let existingType, let newType):
            return NSLocalizedString("ValueRegistryError.typeMismatch: variable \(variableName) is \(existingType) but \(newType) is trying to be set", comment: "ValueRegistryError")
        }
    }
}

struct ValueContainer {
    var value: Value?
    
    init(_ value: Value?) {
        self.value = value
    }
}

class VariableRegistry {
    private let topVariableRegistry: VariableRegistry?
    private var values: [String: ValueContainer] = [:]
    
    init(topVariableRegistry: VariableRegistry? = nil) {
        self.topVariableRegistry = topVariableRegistry
    }
    
    func registerValue(name: String, value: Value?) {
        self.values[name] = ValueContainer(value)
    }
    
    func updateValue(name: String, value: Value?) throws {
        if let oldValue = self.values[name] {
            if let oldValueType = oldValue.value?.type, let newValueType = value?.type {
                guard oldValueType == newValueType else {
                    throw ValueRegistryError.typeMismatch(variableName: name, existingType: oldValueType, newType: newValueType)
                }
            }
            self.values[name] = ValueContainer(value)
            return
        }
        if let upperValueRegistry = self.topVariableRegistry {
            try upperValueRegistry.updateValue(name: name, value: value)
            return
        }
        throw ValueRegistryError.valueDoesNotExist(name: name)
    }
    
    func getValue(name: String) -> Value? {
        return self.values[name]?.value ?? self.topVariableRegistry?.getValue(name: name)
    }
    
    func valueExists(name: String) -> Bool {
        return self.values[name] != nil || (self.topVariableRegistry?.valueExists(name: name) ?? false)
    }
}
